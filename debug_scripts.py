import os
import re

def check_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find definition of tech_panel.gd or any Control script
    # We look for [ext_resource type="Script" path="...tech_panel.gd" id="..."]
    
    script_map = {} # id -> path
    
    # Regex for ext_resource
    # [ext_resource type="Script" path="res://scripts/tech_panel.gd" id="2_premium"]
    ext_res_pattern = re.compile(r'\[ext_resource type="Script" path="([^"]+)" id="([^"]+)"\]')
    
    for match in ext_res_pattern.finditer(content):
        path = match.group(1)
        rid = match.group(2)
        if "tech_panel.gd" in path or "procedural_icon.gd" in path or "pvp_lobby" in path:
            script_map[rid] = path

    if not script_map:
        return

    # Now find usage: script = ExtResource("id")
    # inside a [sub_resource type="StyleBoxFlat" ...] block
    
    lines = content.split('\n')
    current_type = None
    current_id = None
    
    header_pattern = re.compile(r'\[sub_resource type="([^"]+)" id="([^"]+)"\]')
    
    for i, line in enumerate(lines):
        m = header_pattern.match(line)
        if m:
            current_type = m.group(1)
            current_id = m.group(2)
            continue
        
        if current_type == "StyleBoxFlat":
            if "script = ExtResource" in line:
                # Extract ID
                # script = ExtResource("2_premium")
                m_script = re.search(r'script = ExtResource\("([^"]+)"\)', line)
                if m_script:
                    ref_id = m_script.group(1)
                    if ref_id in script_map:
                        print(f"FOUND MISMATCH in {filepath}")
                        print(f"  Resource {current_type} (id={current_id}) uses script {script_map[ref_id]}")
                        print(f"  Line {i+1}: {line.strip()}")

def main():
    root_dir = r"c:\Users\HP\checkers"
    for subdir, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.tscn') or file.endswith('.tres'):
                check_file(os.path.join(subdir, file))

if __name__ == "__main__":
    main()
