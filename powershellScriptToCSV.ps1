class ApplicationLog {
    [string]$ID
    [string]$ProcessDate
    [string]$UserName
    [string]$Name
    [string]$CPU
    [string]$PM
    [string]$GDI
    [string]$WorkingSet
    [string]$Handles
    [string]$Thread
    
}


$GDIDetails
$process_name = 'Code' #Process name (Change process name with your requirements )
$currentTime = Get-Date -format "dd-MMM-yyyy HH:mm:ss"

$procs = Get-Process $process_name |
   Select-Object Name, id, CPU, WorkingSet, Handles, PM

$threadlist = Get-Process $process_name | Select-Object @{Name='ThreadCount';Expression ={$_.Threads.Count}} 

$sig = @'
[DllImport("User32.dll")]
public static extern int GetGuiResources(IntPtr hProcess, int uiFlags);
'@

Add-Type -MemberDefinition $sig -name NativeMethods -namespace Win32

$processes = [System.Diagnostics.Process]::GetProcessesByName($process_name)
[int]$gdiHandleCount = 0
ForEach ($p in $processes)
{
    try{
        $gdiHandles = [Win32.NativeMethods]::GetGuiResources($p.Handle, 0)
		if($gdiHandles -gt 0)
		{
			$gdiHandleCount += $gdiHandles
			$GDIDetails =  $gdiHandles.ToString() 
		}
    }
    catch {
       
    }
}


$dev = [ApplicationLog]::new()
$dev.ID = $procs.Id
$dev.ProcessDate = $currentTime
$dev.UserName = $env:USERNAME
$dev.CPU = $procs.CPU
$dev.Name = $procs.Name
$dev.PM = $procs.PM
$dev.GDI = $GDIDetails
$dev.Handles = $procs.Handles
$dev.WorkingSet = $procs.WorkingSet
$dev.Thread = $threadlist.ThreadCount
$dev

$usernames = $dev.UserName
mkdir $usernames

#Generate csv  file
foreach($proc in $dev){
   $proc | Export-Csv $usernames\process_name_resource_details.csv -NoTypeInformation -Append
}

