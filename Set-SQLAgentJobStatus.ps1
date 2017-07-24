Function Set-SQLAgentJobStatus
{
    [CmdletBinding()]
	Param (
            [parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
            [object]$sqlServer,
            [object]$job,
            [bool]$status
        )

    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null

    ForEach ($s in $sqlServer)
    {
        $serverInstance = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $s
    
        #Change status of job.
        ForEach ($j in $job)
        {
            ForEach ($j in ($serverInstance.JobServer.Jobs | Where-Object {$_.name -eq $j}))
            {
                If ($j.IsEnabled -eq $status)
                {
                    #Do nothing. Job status already set to $status.
                    Write-Host "Job '$j' enabled already $status on '$s'. No action taken."
                } #End If.
                ElseIf ($j.IsEnabled -ne $status)
                {
                    #Set job status to $status.
                    $j.IsEnabled = $status
                    $j.Alter()

                    Write-Host "Job '$j' enabled is now set to $status on '$s'."
                } #End ElseIf.
            } #End ForEach job loop.
        } #End ForEach job in jobList loop.
    } #End ForEach s in serverList loop.
} #End Set-SQLAgentJobStatus funtion.

#SqlServer and job can have single or multiple options (see below). Status 1 is True (enabled), 0 is False (disabled).
#Set-SQLAgentJobStatus -sqlServer "Server1,Server2" -job "Job1" -status 1
#Set-SQLAgentJobStatus -sqlServer "Server1,Server2" -job "Job1,Job2" -status 1