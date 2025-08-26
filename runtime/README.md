# Visual C++ Runtime

This folder contains the Visual C++ Redistributable required for IsotoneStack components.

## Included File

- **vc_redist.x64.exe** - Microsoft Visual C++ 2015-2022 Redistributable (x64)

## Installation

The runtime is automatically installed when you run `Setup-IsotoneStack.ps1`.

For manual installation:
```batch
vc_redist.x64.exe /quiet /norestart
```

## Version Requirements

IsotoneStack components are built with Visual Studio 2022 (VS17) and require:
- Visual C++ 2015-2022 Redistributable (x64) - 14.40.33810 or later

## Download Links

If you need to update the runtime:
- [Latest VC++ 2022 x64](https://aka.ms/vs/17/release/vc_redist.x64.exe)
- [Microsoft Support Page](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)

## Why It's Needed

Apache, PHP, and MariaDB for Windows are compiled with Visual Studio and depend on the Visual C++ runtime libraries. Without this runtime, you'll see errors like:
- "VCRUNTIME140.dll was not found"
- "MSVCP140.dll was not found"
- "The code execution cannot proceed"