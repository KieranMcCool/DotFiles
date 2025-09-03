#!/usr/bin/env python3
"""
This Python script converts a cURL command into Python code using the requests library.
It handles various cURL options and generates equivalent Python code.
It can be used in several ways:
1. As a command-line tool: `python Curl2Python.py 'curl ...'`
2. By piping input: `echo "curl ..." | python Curl2Python.py`
3. Asking user for input: `python Curl2Python.py` and then entering the cURL command, ending with a blank line.
"""

import sys
import re
import argparse
import shlex
import json
from urllib.parse import urlparse, parse_qs


class CurlToPython:
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
            if key.lower() == 'content-type' and value == 'application/json' and self.data:
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

    def generate_python_code(self):
        """Generate Python code using requests library."""
        if not self.url:
            return "# Error: No URL found in curl command"
        
        code_lines = []
        code_lines.append("import requests")
        
        if self.json_data:
            code_lines.append("import json")
        
        code_lines.append("")
        
        # URL
        code_lines.append(f"url = '{self.url}'")
        
        # Headers
        if self.headers:
            code_lines.append("")
            code_lines.append("headers = {")
            for key, value in self.headers.items():
                code_lines.append(f"    '{key}': '{value}',")
            code_lines.append("}")
        
        # Parameters
        if self.params:
            code_lines.append("")
            code_lines.append("params = {")
            for key, values in self.params.items():
                if isinstance(values, list) and len(values) == 1:
                    code_lines.append(f"    '{key}': '{values[0]}',")
                else:
                    code_lines.append(f"    '{key}': {values},")
            code_lines.append("}")
        
        # Data
        if self.json_data:
            code_lines.append("")
            code_lines.append("json_data = " + json.dumps(self.json_data, indent=4))
        elif self.data:
            code_lines.append("")
            if isinstance(self.data, dict):
                code_lines.append("data = {")
                for key, value in self.data.items():
                    code_lines.append(f"    '{key}': '{value}',")
                code_lines.append("}")
            else:
                code_lines.append(f"data = '{self.data}'")
        
        # Files
        if self.files:
            code_lines.append("")
            code_lines.append("files = {")
            for key, filename in self.files.items():
                code_lines.append(f"    '{key}': open('{filename}', 'rb'),")
            code_lines.append("}")
        
        # Cookies
        if self.cookies:
            code_lines.append("")
            code_lines.append("cookies = {")
            for key, value in self.cookies.items():
                code_lines.append(f"    '{key}': '{value}',")
            code_lines.append("}")
        
        # Auth
        if self.auth:
            code_lines.append("")
            code_lines.append(f"auth = ('{self.auth[0]}', '{self.auth[1]}')")
        
        # Proxies
        if self.proxies:
            code_lines.append("")
            code_lines.append("proxies = {")
            for key, value in self.proxies.items():
                code_lines.append(f"    '{key}': '{value}',")
            code_lines.append("}")
        
        # Request call
        code_lines.append("")
        request_args = ["url"]
        
        if self.headers:
            request_args.append("headers=headers")
        if self.params:
            request_args.append("params=params")
        if self.json_data:
            request_args.append("json=json_data")
        elif self.data:
            request_args.append("data=data")
        if self.files:
            request_args.append("files=files")
        if self.cookies:
            request_args.append("cookies=cookies")
        if self.auth:
            request_args.append("auth=auth")
        if self.proxies:
            request_args.append("proxies=proxies")
        if not self.verify:
            request_args.append("verify=False")
        if not self.allow_redirects:
            request_args.append("allow_redirects=False")
        if self.timeout:
            request_args.append(f"timeout={self.timeout}")
        
        method_call = f"response = requests.{self.method.lower()}(\n    " + ",\n    ".join(request_args) + "\n)"
        code_lines.append(method_call)
        
        # Response handling
        code_lines.append("")
        code_lines.append("print(f'Status Code: {response.status_code}')")
        code_lines.append("print(f'Response Headers: {response.headers}')")
        code_lines.append("print(f'Response Content: {response.text}')")
        
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
    """Main function to run the curl to Python converter."""
    parser = argparse.ArgumentParser(description="Convert cURL commands to Python requests code")
    parser.add_argument('curl_command', nargs='*', help='cURL command to convert')
    parser.add_argument('--output', '-o', help='Output file to save Python code')
    
    args = parser.parse_args()
    
    if args.curl_command:
        curl_command = " ".join(args.curl_command)
    else:
        curl_command = get_curl_input()
    
    if not curl_command.strip():
        print("No curl command provided")
        return 1
    
    converter = CurlToPython()
    if converter.parse_curl_command(curl_command):
        python_code = converter.generate_python_code()
        
        if args.output:
            with open(args.output, 'w') as f:
                f.write(python_code)
            print(f"Python code saved to {args.output}")
        else:
            print(python_code)
    else:
        print("Failed to parse curl command")
        return 1
    
    return 0


if __name__ == "__main__":
    sys.exit(main())

