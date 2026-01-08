import os
import re

def check_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Regex to find section headers like [node ...], [sub_resource ...], [ext_resource ...], [resource ...]
    # We want to capture the type if it is sub_resource or resource
    
    # Generic section header: [name key=value ...]
    section_pattern = re.compile(r'^\[(\w+)\s+(.*)\]$')
    
    lines = content.split('\n')
    current_section_type = None
    current_resource_type = None
    current_id = None
    
    # Map ext_resource ids to paths to be helpful
    ext_resources = {} # id -> path
    
    # First pass: gather ext_resources
    for line in lines:
        if line.startswith('[ext_resource'):
            # [ext_resource type="Script" path="res://scripts/tech_panel.gd" id="2_premium"]
            path_m = re.search(r'path="([^"]+)"', line)
            id_m = re.search(r'id="([^"]+)"', line)
            if path_m and id_m:
                ext_resources[id_m.group(1)] = path_m.group(1)

    # Second pass: check sub_resources
    for i, line in enumerate(lines):
        line = line.strip()
        if not line: continue
        
        m = section_pattern.match(line)
        if m:
            section_kind = m.group(1) # node, sub_resource, ext_resource, resource
            attrs = m.group(2)
            
            # Reset current cursors
            current_section_type = section_kind
            current_resource_type = None
            current_id = None
            
            if section_kind == "sub_resource" or section_kind == "resource":
                # Extract type and id
                type_m = re.search(r'type="([^"]+)"', attrs)
                id_m = re.search(r'id="([^"]+)"', attrs)
                
                if type_m: current_resource_type = type_m.group(1)
                if id_m: current_id = id_m.group(1)
            
            continue
        
        # Inside a section
        if current_section_type in ["sub_resource", "resource"] and current_resource_type == "StyleBoxFlat":
            if line.startswith("script ="):
                # script = ExtResource("...")
                # Extract the ID
                ref_m = re.search(r'ExtResource\("([^"]+)"\)', line)
                if ref_m:
                    ref_id = ref_m.group(1)
                    script_path = ext_resources.get(ref_id, "Unknown Connection")
                    print(f"REAL MISMATCH in {filepath}")
                    print(f"  Line {i+1}: StyleBoxFlat (id={current_id}) has script {script_path}")

def main():
    root_dir = r"c:\Users\HP\checkers"
    for subdir, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.tscn') or file.endswith('.tres'):
                check_file(os.path.join(subdir, file))

if __name__ == "__main__":
    main()
