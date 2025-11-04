## Release Notes
- Release: 1.0.7
    - Added the DDLs that do not import with Add-Type in powershell to the Exclude list during the import and during the release
    - Added a check to see if a newer version is released to the PSGallery
    - Version check will perform a Web Request to the PSGallery to check for new stable release, and will compare against the current installed version and will display a message if there is a new version, the check can be silenced with by passing $true as an argument list parameter (Ex. `Import-Module EmailModule -ArgumentList $true`)
- Release: 1.0.6 
    - Added multiple parameter sets for authentication:
        - 'UserPass' parameter set using AuthUser and AuthPass
        - 'PSCredential' parameter set using Credential object
    - Enhanced AuthPass parameter to accept both plain text strings and SecureString objects
    - Added PSCredential parameter as alternative authentication method
    - Added Carbon Copy (CC) support:
        - EmailCc parameter for CC recipients (supports multiple addresses separated by ';')
        - CcName parameter for CC recipient display names
    - Added Blind Carbon Copy (BCC) support:
        - EmailBcc parameter for BCC recipients (supports multiple addresses separated by ';')
        - BccName parameter for BCC recipient display names
    - Enhanced recipient handling:
        - EmailTo parameter now supports multiple recipients separated by ';'
        - EmailToName parameter supports multiple names separated by ';'
        - Automatic fallback to email addresses when name count doesn't match address count
    - Added email attachment support with EmailAttachment parameter
    - Added EmailPriority parameter with values: NonUrgent, Normal, Urgent
    - Added EmailImportance parameter with values: Low, Normal, High
    - Subject and body are NULLABLE
    - Updated nuspec file generation to address warnings and missing files in nuget pack
        - Added dependencies
        - Added readme metadata
        - Updated license metadata
        - Added repository metadata
    - Change dll directories to address nuget pack warnings
        - lib\Core → lib\net8.0
        - lib\Desktop → lib\net472
    - Added License and Readme Property and Item Groups to csproj files
    - Added Warning messages for Authentication User and Sending Email mismatch
    - Added Warning messages for sending email domain and smtp server domain mismatch
    - Added / Validated support for MacOS
    - Added status return after email is sent (EX: 2.0.0 OK)
    - Added Debug messages for debug build
    - Combined and Moved mime message builder methods to separate class
    - Added check for CI environment variable and MacOS and if it returns true it will bypass the OCSP/CRL checks for github actions integration tests

    *** These are non-breaking changes. Any scripts or automation using pervious releases are still supported. All new parameters and features are options and not required. ***

- Release: 1.0.5
    - EmailToName, and EmailFromName are NULLABLE

- Release: 1.0.4
    - All Parameters are required 
    - First production release
