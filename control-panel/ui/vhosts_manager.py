"""
Virtual Hosts Manager with drag-drop site creation
"""

import customtkinter as ctk
import tkinter as tk
from tkinter import filedialog, messagebox
from pathlib import Path
import shutil
import re

class VHostsManager:
    def __init__(self, parent, config, logger):
        self.parent = parent
        self.config = config
        self.logger = logger
        self.vhosts = []
        
        # Create main frame
        self.frame = ctk.CTkScrollableFrame(parent, corner_radius=0)
        
        # Create UI
        self._create_header()
        self._create_vhosts_list()
        self._create_add_form()
        
        # Load existing vhosts
        self._load_vhosts()
        
        # Hide initially
        self.hide()
    
    def _create_header(self):
        """Create header with title and actions"""
        header = ctk.CTkFrame(self.frame, corner_radius=10)
        header.pack(fill="x", padx=20, pady=(20, 10))
        
        title = ctk.CTkLabel(
            header,
            text="Virtual Hosts Manager",
            font=ctk.CTkFont(size=24, weight="bold")
        )
        title.pack(side="left", padx=20, pady=15)
        
        # Add new vhost button
        add_btn = ctk.CTkButton(
            header,
            text="+ Add Virtual Host",
            command=self._toggle_add_form
        )
        add_btn.pack(side="right", padx=20)
        
        # Reload Apache button
        reload_btn = ctk.CTkButton(
            header,
            text="🔄 Reload Apache",
            command=self._reload_apache
        )
        reload_btn.pack(side="right", padx=5)
    
    def _create_vhosts_list(self):
        """Create list of virtual hosts"""
        self.list_frame = ctk.CTkFrame(self.frame, corner_radius=10)
        self.list_frame.pack(fill="both", expand=True, padx=20, pady=10)
        
        # List header
        header = ctk.CTkFrame(self.list_frame, height=40, fg_color=("gray80", "gray20"))
        header.pack(fill="x", padx=2, pady=2)
        
        cols = ["Domain", "Document Root", "Port", "SSL", "Status", "Actions"]
        for i, col in enumerate(cols):
            label = ctk.CTkLabel(header, text=col, font=ctk.CTkFont(weight="bold"))
            label.grid(row=0, column=i, padx=10, pady=5, sticky="w")
    
    def _create_add_form(self):
        """Create add virtual host form"""
        self.add_frame = ctk.CTkFrame(self.frame, corner_radius=10)
        
        # Form title
        title = ctk.CTkLabel(
            self.add_frame,
            text="Add New Virtual Host",
            font=ctk.CTkFont(size=18, weight="bold")
        )
        title.grid(row=0, column=0, columnspan=2, padx=20, pady=(15, 10))
        
        # Domain name
        ctk.CTkLabel(self.add_frame, text="Domain:").grid(row=1, column=0, padx=20, pady=5, sticky="e")
        self.domain_entry = ctk.CTkEntry(self.add_frame, width=300, placeholder_text="example.local")
        self.domain_entry.grid(row=1, column=1, padx=20, pady=5)
        
        # Document root
        ctk.CTkLabel(self.add_frame, text="Document Root:").grid(row=2, column=0, padx=20, pady=5, sticky="e")
        root_frame = ctk.CTkFrame(self.add_frame, fg_color="transparent")
        root_frame.grid(row=2, column=1, padx=20, pady=5)
        
        self.root_entry = ctk.CTkEntry(root_frame, width=250)
        self.root_entry.pack(side="left")
        
        browse_btn = ctk.CTkButton(
            root_frame,
            text="📁",
            width=40,
            command=self._browse_folder
        )
        browse_btn.pack(side="left", padx=(5, 0))
        
        # Port
        ctk.CTkLabel(self.add_frame, text="Port:").grid(row=3, column=0, padx=20, pady=5, sticky="e")
        self.port_entry = ctk.CTkEntry(self.add_frame, width=100, placeholder_text="80")
        self.port_entry.grid(row=3, column=1, padx=20, pady=5, sticky="w")
        
        # SSL
        ctk.CTkLabel(self.add_frame, text="Enable SSL:").grid(row=4, column=0, padx=20, pady=5, sticky="e")
        self.ssl_check = ctk.CTkCheckBox(self.add_frame, text="")
        self.ssl_check.grid(row=4, column=1, padx=20, pady=5, sticky="w")
        
        # Buttons
        btn_frame = ctk.CTkFrame(self.add_frame, fg_color="transparent")
        btn_frame.grid(row=5, column=0, columnspan=2, pady=15)
        
        save_btn = ctk.CTkButton(
            btn_frame,
            text="Save",
            command=self._save_vhost
        )
        save_btn.pack(side="left", padx=5)
        
        cancel_btn = ctk.CTkButton(
            btn_frame,
            text="Cancel",
            fg_color="gray",
            command=self._toggle_add_form
        )
        cancel_btn.pack(side="left", padx=5)
    
    def _toggle_add_form(self):
        """Toggle add form visibility"""
        if self.add_frame.winfo_viewable():
            self.add_frame.pack_forget()
        else:
            self.add_frame.pack(fill="x", padx=20, pady=10)
    
    def _browse_folder(self):
        """Browse for document root folder"""
        folder = filedialog.askdirectory(
            initialdir=self.config.get_isotone_path() / "www"
        )
        if folder:
            self.root_entry.delete(0, tk.END)
            self.root_entry.insert(0, folder)
    
    def _save_vhost(self):
        """Save new virtual host"""
        domain = self.domain_entry.get().strip()
        root = self.root_entry.get().strip()
        port = self.port_entry.get().strip() or "80"
        ssl = self.ssl_check.get()
        
        if not domain or not root:
            messagebox.showerror("Error", "Domain and Document Root are required")
            return
        
        # Create vhost configuration
        vhost_config = self._generate_vhost_config(domain, root, port, ssl)
        
        # Save to Apache config
        vhosts_file = Path(self.config.get("services.apache.path")) / "conf" / "extra" / "httpd-vhosts.conf"
        
        try:
            with open(vhosts_file, "a") as f:
                f.write("\n" + vhost_config)
            
            # Add to hosts file
            self._add_to_hosts_file(domain)
            
            # Create document root if not exists
            Path(root).mkdir(parents=True, exist_ok=True)
            
            # Create default index file
            self._create_default_index(Path(root), domain)
            
            self.logger.info(f"Virtual host {domain} created successfully")
            messagebox.showinfo("Success", f"Virtual host {domain} created successfully")
            
            # Refresh list
            self._load_vhosts()
            
            # Clear form
            self.domain_entry.delete(0, tk.END)
            self.root_entry.delete(0, tk.END)
            self.port_entry.delete(0, tk.END)
            self.ssl_check.deselect()
            self._toggle_add_form()
            
        except Exception as e:
            self.logger.error(f"Failed to create virtual host: {e}")
            messagebox.showerror("Error", f"Failed to create virtual host: {e}")
    
    def _generate_vhost_config(self, domain: str, root: str, port: str, ssl: bool) -> str:
        """Generate Apache virtual host configuration"""
        config = f"""
<VirtualHost *:{port}>
    ServerName {domain}
    DocumentRoot "{root}"
    
    <Directory "{root}">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog "C:/isotone/logs/apache/{domain}-error.log"
    CustomLog "C:/isotone/logs/apache/{domain}-access.log" common
"""
        
        if ssl:
            config += f"""
    SSLEngine on
    SSLCertificateFile "C:/isotone/ssl/{domain}.crt"
    SSLCertificateKeyFile "C:/isotone/ssl/{domain}.key"
"""
        
        config += "</VirtualHost>\n"
        return config
    
    def _add_to_hosts_file(self, domain: str):
        """Add domain to Windows hosts file"""
        hosts_file = Path("C:/Windows/System32/drivers/etc/hosts")
        
        try:
            with open(hosts_file, "r") as f:
                content = f.read()
            
            if domain not in content:
                with open(hosts_file, "a") as f:
                    f.write(f"\n127.0.0.1\t{domain}\n")
                    
        except PermissionError:
            self.logger.warning("Cannot update hosts file - admin rights required")
    
    def _create_default_index(self, root: Path, domain: str):
        """Create default index.html file"""
        index_file = root / "index.html"
        if not index_file.exists():
            content = f"""
<!DOCTYPE html>
<html>
<head>
    <title>{domain}</title>
    <style>
        body {{ font-family: Arial; text-align: center; padding: 50px; }}
        h1 {{ color: #333; }}
    </style>
</head>
<body>
    <h1>Welcome to {domain}</h1>
    <p>Your virtual host is working!</p>
    <p>Document root: {root}</p>
</body>
</html>"""
            index_file.write_text(content)
    
    def _load_vhosts(self):
        """Load existing virtual hosts"""
        # This would parse the Apache vhosts config file
        pass
    
    def _reload_apache(self):
        """Reload Apache configuration"""
        try:
            import subprocess
            apache_path = Path(self.config.get("services.apache.path")) / "bin" / "httpd.exe"
            subprocess.run([str(apache_path), "-k", "restart"], capture_output=True)
            messagebox.showinfo("Success", "Apache configuration reloaded")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to reload Apache: {e}")
    
    def show(self):
        self.frame.grid(row=0, column=0, sticky="nsew", padx=0, pady=0)
    
    def hide(self):
        self.frame.grid_forget()