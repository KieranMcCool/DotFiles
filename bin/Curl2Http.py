#!/usr/bin/env python3
"""
This Python script converts a cURL command into .http file format
that can be used with REST Client plugins in Visual Studio Code and other editors.
It handles various cURL options and generates equivalent .http syntax.
It can be used in several ways:
1. As a command-line tool: `python Curl2Http.py 'curl ...'`
2. By piping input: `echo "curl ..." | python Curl2Http.py`
3. Asking user for input: `python Curl2Http.py` and then entering the cURL command, ending with a blank line.
"""

import sys
import re
import argparse
import shlex
import json
import base64
from urllib.parse import urlparse, parse_qs
from datetime import datetime


class CurlToHttp:
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
                # Keep as form data, set content type
                if not self.content_type:
                    self.content_type = 'application/x-www-form-urlencoded'
            # Otherwise keep as raw data
        
        # If we have data and method is still GET, change to POST
        if self.method == 'GET' and data:
            self.method = 'POST'

    def _parse_auth(self, auth):
        """Parse authentication string."""
        if ':' in auth:
            username, password = auth.split(':', 1)
            self.auth = (username, password)
        else:
            self.auth = (auth, '')

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
                # Regular form field - add to data
                if not self.data:
                    self.data = form_data
                else:
                    self.data += '&' + form_data
                
                if not self.content_type:
                    self.content_type = 'application/x-www-form-urlencoded'
        
        # If we have form data and method is still GET, change to POST
        if self.method == 'GET':
            self.method = 'POST'

    def _parse_proxy(self, proxy):
        """Parse proxy configuration."""
        self.proxies = {'http': proxy, 'https': proxy}

    def _build_url_with_params(self):
        """Build URL with query parameters."""
        if not self.params:
            return self.url
        
        query_parts = []
        for key, values in self.params.items():
            if isinstance(values, list):
                for value in values:
                    query_parts.append(f"{key}={value}")
            else:
                query_parts.append(f"{key}={values}")
        
        return f"{self.url}?{'&'.join(query_parts)}" if query_parts else self.url

    def _format_json_data(self, data):
        """Format JSON data nicely."""
        if isinstance(data, dict) or isinstance(data, list):
            return json.dumps(data, indent=2)
        else:
            try:
                parsed = json.loads(data)
                return json.dumps(parsed, indent=2)
            except (json.JSONDecodeError, TypeError):
                return str(data)

    def generate_http_content(self):
        """Generate .http file content."""
        if not self.url:
            return "# Error: No URL found in curl command"
        
        lines = []
        
        # Add header comment
        lines.append("### Generated from cURL command")
        lines.append(f"# {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        lines.append("")
        
        # Request line with URL and query parameters
        full_url = self._build_url_with_params()
        lines.append(f"{self.method} {full_url}")
        
        # Headers
        for key, value in self.headers.items():
            lines.append(f"{key}: {value}")
        
        # Authentication
        if self.auth:
            username, password = self.auth
            auth_string = base64.b64encode(f"{username}:{password}".encode()).decode()
            lines.append(f"Authorization: Basic {auth_string}")
        
        # Cookies
        if self.cookies:
            cookie_pairs = [f"{key}={value}" for key, value in self.cookies.items()]
            lines.append(f"Cookie: {'; '.join(cookie_pairs)}")
        
        # Content-Type (if we determined one but it's not already in headers)
        if (self.content_type and 
            not any(key.lower() == 'content-type' for key in self.headers.keys())):
            lines.append(f"Content-Type: {self.content_type}")
        
        # Request body
        if self.json_data:
            lines.append("")
            formatted_json = self._format_json_data(self.json_data)
            lines.append(formatted_json)
        elif self.data:
            lines.append("")
            lines.append(self.data)
        elif self.files:
            # For file uploads, show a comment about multipart form data
            lines.append("")
            lines.append("# File uploads detected - you may need to manually configure multipart form data")
            for key, filename in self.files.items():
                lines.append(f"# {key}: {filename}")
        
        # Add helpful comments about .http features
        lines.extend([
            "",
            "###",
            "# .http file features you can use:",
            "# ",
            "# Variables:",
            "# @baseUrl = https://api.example.com",
            "# @authToken = your-token-here",
            "#",
            "# Then use them like:",
            "# GET {{baseUrl}}/users",
            "# Authorization: Bearer {{authToken}}",
            "#",
            "# Multiple requests in same file:",
            "# ###",
            "# POST {{baseUrl}}/users",
            "# Content-Type: application/json",
            "#",
            "# {",
            "#   \"name\": \"John Doe\"",
            "# }",
        ])
        
        # Add comments for unsupported cURL features
        comments = []
        if not self.verify:
            comments.append("# Note: cURL --insecure flag detected (SSL verification disabled)")
        if self.proxies:
            proxy_url = list(self.proxies.values())[0]
            comments.append(f"# Note: cURL proxy detected: {proxy_url}")
        if self.timeout:
            comments.append(f"# Note: cURL timeout detected: {self.timeout}s")
        
        if comments:
            lines.extend([""] + comments)
        
        return "\n".join(lines)


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
    """Main function to run the curl to .http converter."""
    parser = argparse.ArgumentParser(description="Convert cURL commands to .http file format for REST Client plugins")
    parser.add_argument('curl_command', nargs='*', help='cURL command to convert')
    parser.add_argument('--output', '-o', help='Output file to save .http content (should end with .http)')
    parser.add_argument('--name', '-n', help='Name/title for the request (used in comments)')
    
    args = parser.parse_args()
    
    if args.curl_command:
        curl_command = " ".join(args.curl_command)
    else:
        curl_command = get_curl_input()
    
    if not curl_command.strip():
        print("No curl command provided")
        return 1
    
    converter = CurlToHttp()
    if converter.parse_curl_command(curl_command):
        http_content = converter.generate_http_content()
        
        # Add custom name if provided
        if args.name:
            http_content = http_content.replace(
                "### Generated from cURL command",
                f"### {args.name}"
            )
        
        if args.output:
            # Suggest .http extension if not present
            output_file = args.output
            if not output_file.endswith('.http'):
                print(f"Note: Consider using .http extension. Saving to {output_file}")
            
            with open(output_file, 'w') as f:
                f.write(http_content)
            print(f".http file saved to: {output_file}")
        else:
            print(http_content)
    else:
        print("Failed to parse curl command")
        return 1
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
