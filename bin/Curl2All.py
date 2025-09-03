#!/usr/bin/env python3
"""
This Python script converts a cURL command into multiple formats:
1. Python requests code (.py)
2. C# HttpClient code (.cs)
3. .http file format (.http)

It can be used in several ways:
1. As a command-line tool: `python Curl2All.py 'curl ...'`
2. By piping input: `echo "curl ..." | python Curl2All.py`
3. Asking user for input: `python Curl2All.py` and then entering the cURL command

Files will be generated with the format:
{sortable_timestamp}_{request_verb}_{request_url}.{file_extension}
"""

import sys
import os
import re
import argparse
import shlex
import subprocess
from datetime import datetime
from urllib.parse import urlparse
import tempfile


class CurlToAll:
    def __init__(self, output_dir="."):
        self.output_dir = os.path.abspath(output_dir)
        self.script_dir = os.path.dirname(os.path.abspath(__file__))
        self.converters = {
            'Python': ('Curl2Python.py', '.py'),
            'C#': ('Curl2CSharp.py', '.cs'),
            'HTTP': ('Curl2Http.py', '.http')
        }
    
    def extract_http_method(self, curl_command):
        """Extract HTTP method from curl command."""
        method = 'GET'
        
        # Look for -X or --request flag
        if re.search(r'-X\s+([A-Z]+)', curl_command):
            match = re.search(r'-X\s+([A-Z]+)', curl_command)
            method = match.group(1)
        elif re.search(r'--request\s+([A-Z]+)', curl_command):
            match = re.search(r'--request\s+([A-Z]+)', curl_command)
            method = match.group(1)
        elif re.search(r'(-d|--data|--data-raw|--data-binary)', curl_command):
            # If data is present but no method specified, assume POST
            method = 'POST'
        
        return method
    
    def extract_url(self, curl_command):
        """Extract and clean URL from curl command."""
        # Look for URL (http:// or https://)
        url_match = re.search(r'(https?://[^\s\'\"]+)', curl_command)
        if url_match:
            url = url_match.group(1)
            # Parse URL to get clean domain and path
            parsed = urlparse(url)
            # Remove query parameters and fragments for filename
            clean_url = f"{parsed.netloc}{parsed.path}"
            # Replace special characters for filename
            clean_url = re.sub(r'[^a-zA-Z0-9._-]', '_', clean_url)
            return clean_url
        else:
            return "unknown_url"
    
    def generate_timestamp(self):
        """Generate sortable timestamp."""
        return datetime.now().strftime("%Y%m%d_%H%M%S")
    
    def generate_base_filename(self, curl_command):
        """Generate base filename from curl command."""
        timestamp = self.generate_timestamp()
        method = self.extract_http_method(curl_command)
        url = self.extract_url(curl_command)
        
        return f"{timestamp}_{method}_{url}"
    
    def check_converter_scripts(self):
        """Check if all required converter scripts exist and are executable."""
        missing_scripts = []
        
        for name, (script_name, ext) in self.converters.items():
            script_path = os.path.join(self.script_dir, script_name)
            if not os.path.isfile(script_path):
                missing_scripts.append(script_name)
            elif not os.access(script_path, os.X_OK):
                print(f"Warning: {script_name} is not executable. Making it executable...")
                os.chmod(script_path, 0o755)
        
        if missing_scripts:
            print(f"Error: Missing required scripts in {self.script_dir}:")
            for script in missing_scripts:
                print(f"  - {script}")
            return False
        
        return True
    
    def ensure_output_directory(self):
        """Create output directory if it doesn't exist."""
        if not os.path.exists(self.output_dir):
            print(f"Creating output directory: {self.output_dir}")
            os.makedirs(self.output_dir, exist_ok=True)
    
    def run_converter(self, name, script_name, output_file, curl_command):
        """Run a single converter script."""
        script_path = os.path.join(self.script_dir, script_name)
        
        try:
            print(f"Generating {name} code...")
            
            # Run the converter script
            result = subprocess.run([
                'python', script_path, 
                '--output', output_file,
                curl_command
            ], capture_output=True, text=True, check=True)
            
            print(f"✓ {name}: {output_file}")
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"✗ Failed to generate {name} code")
            if e.stderr:
                print(f"Error: {e.stderr.strip()}")
            return False
        except Exception as e:
            print(f"✗ Failed to generate {name} code: {str(e)}")
            return False
    
    def convert_curl_to_all(self, curl_command):
        """Convert curl command to all formats."""
        if not curl_command.strip():
            print("Error: No curl command provided")
            return False
        
        # Check if converter scripts exist
        if not self.check_converter_scripts():
            return False
        
        # Ensure output directory exists
        self.ensure_output_directory()
        
        # Generate base filename
        base_filename = self.generate_base_filename(curl_command)
        
        print("Processing cURL command...")
        print(f"Base filename: {base_filename}")
        print("")
        
        # Convert to all formats
        success_count = 0
        total_count = len(self.converters)
        generated_files = {}
        
        for name, (script_name, extension) in self.converters.items():
            output_file = os.path.join(self.output_dir, f"{base_filename}{extension}")
            
            if self.run_converter(name, script_name, output_file, curl_command):
                success_count += 1
                generated_files[name] = output_file
        
        # Summary
        print("")
        print("Summary:")
        print(f"Successfully generated {success_count} out of {total_count} files")
        
        if success_count == total_count:
            print("All conversions completed successfully!")
            print("")
            print("Generated files:")
            for name, file_path in generated_files.items():
                print(f"  {name:8}: {file_path}")
            return True
        else:
            print("Some conversions failed. Check the errors above.")
            if generated_files:
                print("")
                print("Successfully generated files:")
                for name, file_path in generated_files.items():
                    print(f"  {name:8}: {file_path}")
            return False


def get_curl_input():
    """Get curl command from various input sources."""
    if len(sys.argv) > 1:
        # Check if it's an option or the curl command
        args = sys.argv[1:]
        curl_parts = []
        i = 0
        while i < len(args):
            if args[i] in ['-d', '--dir']:
                i += 2  # Skip the option and its value
            elif args[i] in ['-h', '--help']:
                i += 1
            else:
                curl_parts.extend(args[i:])
                break
            i += 1
        
        if curl_parts:
            return " ".join(curl_parts)
    
    if not sys.stdin.isatty():
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
    """Main function."""
    parser = argparse.ArgumentParser(
        description="Convert cURL commands to Python, C#, and .http formats",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python Curl2All.py 'curl -X POST https://api.example.com/users -H "Content-Type: application/json" -d "{\\"name\\":\\"John\\"}"'
  echo 'curl -X GET https://api.example.com/users' | python Curl2All.py
  python Curl2All.py --dir ./output 'curl ...'

Files will be generated with the format:
{sortable_timestamp}_{request_verb}_{request_url}.{file_extension}

If no curl command is provided as argument and no input is piped,
the script will prompt for interactive input.
        """
    )
    
    parser.add_argument('curl_command', nargs='*', help='cURL command to convert')
    parser.add_argument('--dir', '-d', default='.', 
                       help='Output directory for generated files (default: current directory)')
    
    args = parser.parse_args()
    
    # Get curl command
    if args.curl_command:
        curl_command = " ".join(args.curl_command)
    else:
        curl_command = get_curl_input()
    
    if not curl_command.strip():
        print("Error: No curl command provided")
        parser.print_help()
        return 1
    
    # Create converter and run
    converter = CurlToAll(output_dir=args.dir)
    
    if converter.convert_curl_to_all(curl_command):
        return 0
    else:
        return 1


if __name__ == "__main__":
    sys.exit(main())
