# Automation of Example Scripts
The simplest way on windows would be to setup a task in Task Scheduler, example below is 

```xml
<Exec>
    <Command>powershell.exe</Command>
    <Arguments>-NoProfile -ExecutionPolicy Bypass -File "File\Path\ExampleScript.ps1"</Arguments>
</Exec>
```
