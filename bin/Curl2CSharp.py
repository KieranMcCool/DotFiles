#!/usr/bin/env python3
"""
This Python script converts a cURL command into C# code using HttpClient.
It handles various cURL options and generates equivalent C# code.
It can be used in several ways:
1. As a command-line tool: `python Curl2CSharp.py 'curl ...'`
2. By piping input: `echo "curl ..." | python Curl2CSharp.py`
3. Asking user for input: `python Curl2CSharp.py` and then entering the cURL command, ending with a blank line.
"""

import sys
import re
import argparse
import shlex
import json
from urllib.parse import urlparse, parse_qs


class CurlToCSharp:
    def __init__(self):
        self.method = 'GET'
        self.url = ''
        self.headers = {}
        self.data = None
        self.json_data = None
        self.params = {}
        self.auth = None
        self.cookies = {}
        self.files = {}
        self.verify = True
        self.allow_redirects = True
        self.timeout = None
        self.proxies = {}
        self.content_type = None

    def parse_curl_command(self, curl_command):
        """Parse a cURL command and extract relevant information."""
        # Remove 'curl' from the beginning and clean up the command
        curl_command = curl_command.strip()
        if curl_command.startswith('curl'):
            curl_command = curl_command[4:].strip()
        
        # Use shlex to properly split the command while respecting quotes
        try:
            tokens = shlex.split(curl_command)
        except ValueError as e:
            print(f"Error parsing curl command: {e}")
            return False

        i = 0
        while i < len(tokens):
            token = tokens[i]
            
            if token in ['-X', '--request']:
                i += 1
                if i < len(tokens):
                    self.method = tokens[i].upper()
            
            elif token in ['-H', '--header']:
                i += 1
                if i < len(tokens):
                    self._parse_header(tokens[i])
            
            elif token in ['-d', '--data', '--data-raw']:
                i += 1
                if i < len(tokens):
                    self._parse_data(tokens[i])
            
            elif token in ['--data-binary']:
                i += 1
                if i < len(tokens):
                    self.data = tokens[i]
            
            elif token in ['-u', '--user']:
                i += 1
                if i < len(tokens):
                    self._parse_auth(tokens[i])
            
            elif token in ['-b', '--cookie']:
                i += 1
                if i < len(tokens):
                    self._parse_cookies(tokens[i])
            
            elif token in ['-F', '--form']:
                i += 1
                if i < len(tokens):
                    self._parse_form_data(tokens[i])
            
            elif token in ['-k', '--insecure']:
                self.verify = False
            
            elif token in ['-L', '--location']:
                self.allow_redirects = True
            
            elif token in ['--max-time']:
                i += 1
                if i < len(tokens):
                    self.timeout = float(tokens[i])
            
            elif token in ['--proxy']:
                i += 1
                if i < len(tokens):
                    self._parse_proxy(tokens[i])
            
            elif token.startswith('http://') or token.startswith('https://'):
                self.url = token
                # Parse query parameters from URL
                parsed_url = urlparse(token)
                if parsed_url.query:
                    self.params.update(parse_qs(parsed_url.query, keep_blank_values=True))
                    # Remove query string from URL
                    self.url = token.split('?')[0]
            
            elif token.startswith('-'):
                # Skip unknown options
                pass
            
            else:
                # Assume it's the URL if we haven't found one yet
                if not self.url:
                    self.url = token
                    parsed_url = urlparse(token)
                    if parsed_url.query:
                        self.params.update(parse_qs(parsed_url.query, keep_blank_values=True))
                        self.url = token.split('?')[0]
            
            i += 1
        
        return True

    def _parse_header(self, header):
        """Parse a header string and add it to headers dict."""
        if ':' in header:
            key, value = header.split(':', 1)
            key = key.strip()
            value = value.strip()
            
            # Handle special headers
            if key.lower() == 'content-type':
                self.content_type = value
                if value == 'application/json' and self.data:
                    try:
                        self.json_data = json.loads(self.data)
                        self.data = None
                    except json.JSONDecodeError:
                        pass
            
            self.headers[key] = value

    def _parse_data(self, data):
        """Parse data and determine if it's JSON, form data, or raw data."""
        self.data = data
        
        # Try to parse as JSON
        try:
            self.json_data = json.loads(data)
            self.data = None
            if not self.content_type:
                self.content_type = 'application/json'
        except json.JSONDecodeError:
            # Check if it looks like form data
            if '=' in data and '&' in data:
                # Parse as form data
                params = data.split('&')
                form_data = {}
                for param in params:
                    if '=' in param:
                        key, value = param.split('=', 1)
                        form_data[key] = value
                self.data = form_data
                if not self.content_type:
                    self.content_type = 'application/x-www-form-urlencoded'
            # Otherwise keep as raw data

    def _parse_auth(self, auth):
        """Parse authentication string."""
        if ':' in auth:
            username, password = auth.split(':', 1)
            self.auth = (username, password)

    def _parse_cookies(self, cookies):
        """Parse cookies string."""
        for cookie in cookies.split(';'):
            if '=' in cookie:
                key, value = cookie.split('=', 1)
                self.cookies[key.strip()] = value.strip()

    def _parse_form_data(self, form_data):
        """Parse form data for file uploads or form fields."""
        if '=' in form_data:
            key, value = form_data.split('=', 1)
            if value.startswith('@'):
                # File upload
                filename = value[1:]
                self.files[key] = filename
            else:
                # Regular form field
                if not self.data:
                    self.data = {}
                if isinstance(self.data, dict):
                    self.data[key] = value

    def _parse_proxy(self, proxy):
        """Parse proxy configuration."""
        self.proxies = {'http': proxy, 'https': proxy}

    def _escape_csharp_string(self, s):
        """Escape a string for C# string literals."""
        return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')

    def _build_query_string(self):
        """Build query string from parameters."""
        if not self.params:
            return ""
        
        query_parts = []
        for key, values in self.params.items():
            if isinstance(values, list):
                for value in values:
                    query_parts.append(f"{key}={value}")
            else:
                query_parts.append(f"{key}={values}")
        
        return "?" + "&".join(query_parts) if query_parts else ""

    def generate_csharp_code(self):
        """Generate C# code using HttpClient."""
        if not self.url:
            return "// Error: No URL found in curl command"
        
        code_lines = []
        
        # Using statements
        code_lines.append("using System;")
        code_lines.append("using System.Net.Http;")
        code_lines.append("using System.Text;")
        code_lines.append("using System.Threading.Tasks;")
        if self.json_data or self.content_type == 'application/json':
            code_lines.append("using Newtonsoft.Json;")
        if self.files:
            code_lines.append("using System.IO;")
        if self.auth:
            code_lines.append("using System.Net.Http.Headers;")
        code_lines.append("")
        
        # Class declaration
        code_lines.append("public class HttpClientExample")
        code_lines.append("{")
        code_lines.append("    public static async Task Main(string[] args)")
        code_lines.append("    {")
        
        # HttpClient setup
        if not self.verify or self.proxies:
            code_lines.append("        var handler = new HttpClientHandler();")
            if not self.verify:
                code_lines.append("        handler.ServerCertificateCustomValidationCallback = (sender, cert, chain, sslPolicyErrors) => true;")
            if self.proxies:
                proxy_url = list(self.proxies.values())[0]
                code_lines.append(f"        handler.Proxy = new System.Net.WebProxy(\"{self._escape_csharp_string(proxy_url)}\");")
            code_lines.append("        using var client = new HttpClient(handler);")
        else:
            code_lines.append("        using var client = new HttpClient();")
        
        # Timeout
        if self.timeout:
            code_lines.append(f"        client.Timeout = TimeSpan.FromSeconds({self.timeout});")
        
        # Default headers
        if self.headers:
            code_lines.append("")
            for key, value in self.headers.items():
                if key.lower() not in ['content-type', 'authorization']:
                    code_lines.append(f"        client.DefaultRequestHeaders.Add(\"{self._escape_csharp_string(key)}\", \"{self._escape_csharp_string(value)}\");")
        
        # Authentication
        if self.auth:
            code_lines.append("")
            username, password = self.auth
            code_lines.append(f"        var authToken = Convert.ToBase64String(Encoding.ASCII.GetBytes(\"{self._escape_csharp_string(username)}:{self._escape_csharp_string(password)}\"));")
            code_lines.append("        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(\"Basic\", authToken);")
        
        # URL with query parameters
        full_url = self.url + self._build_query_string()
        code_lines.append("")
        code_lines.append(f"        var url = \"{self._escape_csharp_string(full_url)}\";")
        
        # Content preparation
        content_var = None
        if self.json_data:
            code_lines.append("")
            json_string = json.dumps(self.json_data, indent=12).replace('\n', '\n        ')
            code_lines.append(f"        var jsonData = @\"{self._escape_csharp_string(json.dumps(self.json_data))}\";")
            code_lines.append("        var content = new StringContent(jsonData, Encoding.UTF8, \"application/json\");")
            content_var = "content"
        elif isinstance(self.data, dict):
            code_lines.append("")
            code_lines.append("        var formData = new List<KeyValuePair<string, string>>");
            code_lines.append("        {")
            for key, value in self.data.items():
                code_lines.append(f"            new KeyValuePair<string, string>(\"{self._escape_csharp_string(key)}\", \"{self._escape_csharp_string(str(value))}\"),")
            code_lines.append("        };")
            code_lines.append("        var content = new FormUrlEncodedContent(formData);")
            content_var = "content"
        elif self.data:
            code_lines.append("")
            content_type = self.content_type or "text/plain"
            code_lines.append(f"        var content = new StringContent(\"{self._escape_csharp_string(self.data)}\", Encoding.UTF8, \"{content_type}\");")
            content_var = "content"
        elif self.files:
            code_lines.append("")
            code_lines.append("        var content = new MultipartFormDataContent();")
            for key, filename in self.files.items():
                code_lines.append(f"        var fileContent = new ByteArrayContent(File.ReadAllBytes(\"{self._escape_csharp_string(filename)}\"));")
                code_lines.append(f"        content.Add(fileContent, \"{self._escape_csharp_string(key)}\", \"{self._escape_csharp_string(filename)}\");")
            content_var = "content"
        
        # Additional headers for content
        if content_var and self.headers:
            for key, value in self.headers.items():
                if key.lower() == 'content-type' and not self.files:  # Don't set content-type for multipart
                    continue  # Already set in StringContent constructor
                elif key.lower() not in ['authorization']:
                    code_lines.append(f"        content.Headers.Add(\"{self._escape_csharp_string(key)}\", \"{self._escape_csharp_string(value)}\");")
        
        # HTTP request
        code_lines.append("")
        code_lines.append("        try")
        code_lines.append("        {")
        
        if self.method.upper() == 'GET':
            code_lines.append("            var response = await client.GetAsync(url);")
        elif self.method.upper() == 'POST':
            if content_var:
                code_lines.append(f"            var response = await client.PostAsync(url, {content_var});")
            else:
                code_lines.append("            var response = await client.PostAsync(url, null);")
        elif self.method.upper() == 'PUT':
            if content_var:
                code_lines.append(f"            var response = await client.PutAsync(url, {content_var});")
            else:
                code_lines.append("            var response = await client.PutAsync(url, null);")
        elif self.method.upper() == 'DELETE':
            code_lines.append("            var response = await client.DeleteAsync(url);")
        else:
            # Generic method
            if content_var:
                code_lines.append(f"            var request = new HttpRequestMessage(HttpMethod.{self.method.title()}, url);")
                code_lines.append(f"            request.Content = {content_var};")
                code_lines.append("            var response = await client.SendAsync(request);")
            else:
                code_lines.append(f"            var response = await client.SendAsync(new HttpRequestMessage(HttpMethod.{self.method.title()}, url));")
        
        # Response handling
        code_lines.append("")
        code_lines.append("            Console.WriteLine($\"Status Code: {response.StatusCode}\");")
        code_lines.append("            Console.WriteLine($\"Response Headers: {response.Headers}\");")
        code_lines.append("            ")
        code_lines.append("            var responseContent = await response.Content.ReadAsStringAsync();")
        code_lines.append("            Console.WriteLine($\"Response Content: {responseContent}\");")
        code_lines.append("        }")
        code_lines.append("        catch (HttpRequestException ex)")
        code_lines.append("        {")
        code_lines.append("            Console.WriteLine($\"Request error: {ex.Message}\");")
        code_lines.append("        }")
        code_lines.append("        catch (Exception ex)")
        code_lines.append("        {")
        code_lines.append("            Console.WriteLine($\"General error: {ex.Message}\");")
        code_lines.append("        }")
        
        code_lines.append("    }")
        code_lines.append("}")
        
        return "\n".join(code_lines)


def get_curl_input():
    """Get curl command from various input sources."""
    if len(sys.argv) > 1:
        # Command line argument
        return " ".join(sys.argv[1:])
    elif not sys.stdin.isatty():
        # Piped input
        return sys.stdin.read().strip()
    else:
        # Interactive input
        print("Enter your curl command (press Enter twice to finish):")
        lines = []
        while True:
            try:
                line = input()
                if line.strip() == "":
                    break
                lines.append(line)
            except EOFError:
                break
        return " ".join(lines)


def main():
    """Main function to run the curl to C# converter."""
    parser = argparse.ArgumentParser(description="Convert cURL commands to C# HttpClient code")
    parser.add_argument('curl_command', nargs='*', help='cURL command to convert')
    parser.add_argument('--output', '-o', help='Output file to save C# code')
    
    args = parser.parse_args()
    
    if args.curl_command:
        curl_command = " ".join(args.curl_command)
    else:
        curl_command = get_curl_input()
    
    if not curl_command.strip():
        print("No curl command provided")
        return 1
    
    converter = CurlToCSharp()
    if converter.parse_curl_command(curl_command):
        csharp_code = converter.generate_csharp_code()
        
        if args.output:
            with open(args.output, 'w') as f:
                f.write(csharp_code)
            print(f"C# code saved to {args.output}")
        else:
            print(csharp_code)
    else:
        print("Failed to parse curl command")
        return 1
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
