# Build from source

### Download Repo as a ZIP
```powershell
Expand-Archive ".\Powershell_Email-Module-main.zip" ".\Powershell_Email-Module-main"
```

```powershell
Set-Location ".\Powershell_Email-Module-main\Powershell_Email-Module-main\"
```

### Download Repo with Git
```
git clone https://github.com/Brandon-J-Navarro/Powershell_Email-Module.git
```

```powershell
Set-Location .\Powershell_Email-Module\
```

## Restore NuGet packages for .NET Framework Build
```
nuget restore .\EmailLibraryDesktop\EmailLibrary.sln
```

## Build .NET Framework project
```
msbuild .\EmailLibraryDesktop\EmailLibrary.sln /p:Configuration=Release /p:Platform="Any CPU" /p:TargetFrameworkVersion="v4.7.2"
```

## Create release directories
```powershell
New-Item -ItemType Directory -Path "release" | Out-Null;
New-Item -ItemType Directory -Path ".\release\EmailModule" | Out-Null;
New-Item -ItemType Directory -Path ".\release\EmailModule\lib" | Out-Null;
New-Item -ItemType Directory -Path ".\release\EmailModule\lib\net8.0" | Out-Null;
New-Item -ItemType Directory -Path ".\release\EmailModule\lib\net472" | Out-Null;
```

## Copy .NET Framework build output to lib Desktop directory
```powershell
Get-ChildItem -path ".\EmailLibraryDesktop\EmailLibrary\bin\Release\" -Recurse -Exclude "*.pdb" | ForEach-Object {
    Copy-Item $_ -Destination ".\release\EmailModule\lib\net472\"
}
```

## Install dependencies .NET Core Build
```
dotnet restore .\EmailLibraryCore\EmailLibrary\EmailLibrary.csproj
```

## Build .NET Core project
```
dotnet build .\EmailLibraryCore\EmailLibrary\EmailLibrary.csproj --configuration Release --no-restore
```

## Publish .NET Core project
```
dotnet publish .\EmailLibraryCore\EmailLibrary\EmailLibrary.csproj --configuration Release --no-restore --output publish
```

## Copy .NET Core publish output to lib Core directory
```powershell
Get-ChildItem -path ".\publish\" -Exclude "*.pdb" | Where-Object Attributes -ne Directory | ForEach-Object {
    Copy-Item $_ -Destination ".\release\EmailModule\lib\net8.0\"
}
```

## Copy powershell module to release directory
```powershell
Copy-Item -Path ".\EmailModule\EmailModule.Libraries.ps1" -Destination ".\release\EmailModule\"
Copy-Item -Path ".\EmailModule\EmailModule.psm1" -Destination ".\release\EmailModule\"
```

### `Files within the .\release\EmailModule\ directory is the Email Module, copy the EmailModule folder where it is accessible to $env:PSModulePath`
