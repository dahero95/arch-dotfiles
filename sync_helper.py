#!/usr/bin/env python3

import os
import sys
import json
import hashlib
from pathlib import Path
from typing import Dict, List


class SignatureManager:
    def __init__(self, signatures_dir: str):
        self.signatures_dir = Path(signatures_dir)
        self.signatures_dir.mkdir(exist_ok=True)
    
    def _calculate_file_hash(self, file_path: Path) -> str:
        """Calcula SHA256 de un archivo"""
        hasher = hashlib.sha256()
        try:
            with open(file_path, 'rb') as f:
                for chunk in iter(lambda: f.read(4096), b""):
                    hasher.update(chunk)
            return hasher.hexdigest()
        except Exception:
            return ""
    
    def _calculate_dir_signature(self, dir_path: str) -> Dict[str, str]:
        """Calcula firmas de todos los archivos en un directorio"""
        dir_path = Path(dir_path)
        signatures = {}
        if not dir_path.exists():
            return signatures
        
        for file_path in dir_path.rglob('*'):
            if file_path.is_file() and not file_path.name.startswith('.'):
                rel_path = str(file_path.relative_to(dir_path))
                signatures[rel_path] = self._calculate_file_hash(file_path)
        
        return signatures
    
    def save_signatures(self, component: str, source_dir: str):
        """Guarda las firmas de un componente"""
        source_path = Path(source_dir)
        if not source_path.exists():
            return
        
        signatures = self._calculate_dir_signature(source_dir)
        signature_file = self.signatures_dir / f"{component}.json"
        
        with open(signature_file, 'w') as f:
            json.dump(signatures, f, indent=2)
    
    def load_signatures(self, component: str) -> Dict[str, str]:
        """Carga las firmas de un componente"""
        signature_file = self.signatures_dir / f"{component}.json"
        if not signature_file.exists():
            return {}
        
        try:
            with open(signature_file, 'r') as f:
                return json.load(f)
        except Exception:
            return {}
    
    def has_changes(self, component: str, source_dir: str) -> bool:
        """Verifica si hay cambios en un componente"""
        current_signatures = self._calculate_dir_signature(source_dir)
        saved_signatures = self.load_signatures(component)
        
        return current_signatures != saved_signatures
    
    def get_changed_files(self, component: str, source_dir: str) -> List[str]:
        """Obtiene lista de archivos que cambiaron"""
        current_signatures = self._calculate_dir_signature(source_dir)
        saved_signatures = self.load_signatures(component)
        
        changed_files = []
        
        # Archivos nuevos o modificados
        for file_path, signature in current_signatures.items():
            if file_path not in saved_signatures or saved_signatures[file_path] != signature:
                changed_files.append(file_path)
        
        # Archivos eliminados
        for file_path in saved_signatures:
            if file_path not in current_signatures:
                changed_files.append(f"DELETED: {file_path}")
        
        return changed_files

def main():
    if len(sys.argv) < 3:
        print("Usage: python3 sync_helper.py <command> <component> [source_dir]")
        sys.exit(1)
    
    command = sys.argv[1]
    component = sys.argv[2]
    signatures_dir = os.environ.get('SIGNATURES_DIR', '.signatures')
    
    sm = SignatureManager(signatures_dir)
    
    if command == "save":
        if len(sys.argv) < 4:
            print("Usage: python3 sync_helper.py save <component> <source_dir>")
            sys.exit(1)
        source_dir = sys.argv[3]
        sm.save_signatures(component, source_dir)
        print(f"Signatures saved for {component}")
    
    elif command == "check":
        if len(sys.argv) < 4:
            print("Usage: python3 sync_helper.py check <component> <source_dir>")
            sys.exit(1)
        source_dir = sys.argv[3]
        has_changes = sm.has_changes(component, source_dir)
        print("true" if has_changes else "false")
    
    elif command == "changes":
        if len(sys.argv) < 4:
            print("Usage: python3 sync_helper.py changes <component> <source_dir>")
            sys.exit(1)
        source_dir = sys.argv[3]
        changes = sm.get_changed_files(component, source_dir)
        for change in changes:
            print(change)

if __name__ == "__main__":
    main()
