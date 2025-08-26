### Never Do These
- ❌ Don't hardcode paths other than `C:\isotone`
- ❌ Don't modify Windows registry (except for auto-start)
- ❌ Don't use deprecated PHP/Apache features
- ❌ Don't commit binary files to git
- ❌ Don't store passwords in plain text
- ❌ Don't include user data in `/www/`
- ❌ Never remove configuration files from bundled components - IsotoneStack modifies configs in place like XAMPP

### Always Do These
- ✅ Check for Administrator privileges
- ✅ Use relative paths within isotone directory
- ✅ Handle Windows path separators (`\` vs `/`)
- ✅ Include error handling and logging
- ✅ Test on both Windows 10 and 11
- ✅ Keep configurations portable