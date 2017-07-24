Function New-DbaJobs
{
    [CmdletBinding()]
	Param (
            [parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
            [object]$sqlServer,
            [int]$jobsToCreate
        )

    #Connect to SQL.
    Import-Module sqlserver;
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null;
    $server = New-Object Microsoft.SqlServer.Management.Smo.Server $sqlServer;
    Try{$server.ConnectionContext.Connect()} Catch{Throw "Can't connect to SQL Server $sqlServer."}

    $jobs = 1;

    While ($jobs -le $jobsToCreate)
    {
        $steps = (Get-Random -Minimum 1 -Maximum 10); #Random number of steps (1-10).
        $s = 1;
    
        #Create job.
        $jb = New-Object Microsoft.SqlServer.Management.Smo.Agent.Job($server.JobServer, "DBA - Test Job #$jobs")
        $jb.OwnerLoginName = "sa"
        $jb.Create()
    
        While($s -le $steps)
        {
            $wait = (Get-Random -Minimum 1 -Maximum 10);
        
            #Create step(s).
            $js = New-Object ('Microsoft.SqlServer.Management.Smo.Agent.JobStep') ($jb, "Step $s")
            $js.Command = "WAITFOR DELAY '00:0$wait';" #Random wait time seconds (1-10).
            $js.OnSuccessAction = 'QuitWithSuccess'
            $js.OnFailAction = 'QuitWithFailure'
            $js.Create()

            $s++;
        } #End While s in steps loop.

        #Set start step.
        $jsid = 1
        $jb.ApplyToTargetServer($server.Name)
        $jb.StartStepID = $jsid
        $jb.Alter()

        $jobs++;
    } #End While jobs in jobsToCreate loop.

    #Disconnect from SQL.
    $server.ConnectionContext.Disconnect();
} #End New-DbaJobs function.

#New-DbaJobs -sqlServer Server1 -jobsToCreate 2