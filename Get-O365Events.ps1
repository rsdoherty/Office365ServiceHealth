<# 
    .Synopsis 
      Gets office 365 events 
    .DESCRIPTION 
       Gets Office 365 events 
    .EXAMPLE 
       get-O365Events 
    .EXAMPLE 
    [last needs to be a number, it returns the last however many you specify] 
      get-O365Events -last 5  
    #>
    $cred = Get-Credential
    function Get-O365Events 
    { 
        [CmdletBinding()] 
        [Alias()] 
        [OutputType([int])] 
        Param 
        ( 
            # Param1 help description 
            [Parameter(Mandatory=$false, 
                       ValueFromPipelineByPropertyName=$false, 
                       Position=0)] 
            [int]$last = 0 
     
           
        ) 
     
        Begin 
        {
        $Json = (@{userName=$cred.username;password=$cred.GetNetworkCredential().password;} | convertto-json).tostring() 
        $cookie = (invoke-restmethod -contenttype "application/json" -method Post -uri "https://api.admin.microsoftonline.com/shdtenantcommunications.svc/Register" -body $json).RegistrationCookie 
        #"0" to represents a Service Incident, "1" to represent a Maintenance Event, and "2" to represent a Message Center communication  
        $load = (@{lastCookie=$cookie;locale="en-US";preferredEventTypes=@(0,1);} | convertto-json).tostring() 
        $events = (invoke-restmethod -contenttype "application/json" -method Post -uri "https://api.admin.microsoftonline.com/shdtenantcommunications.svc/GetEvents" -body $load) 
        } 
        Process 
        { 
        $newEvent = foreach($evnt in $events.events){ 
                                  New-Object psobject -Property @{ 
                                                                ID = $evnt.ID 
                                                                Title = $evnt.Title 
                                                                ServiceAftected = $evnt.AffectedServiceHealthStatus.servicename 
                                                                Status = $evnt.Status 
                                                                Time = $evnt.starttime 
                                                                LastUpdated = $evnt.LastUpdatedTime 
                                                                Message = $evnt.messages.messagetext 
                                                               }  
                                                                
                                    } 
        } 
        End 
        { 
       if($last -eq 0){$last = 10} 
        $newEvent| sort $_.Time  |   select -Property Title,ServiceAftected,Status, Time,LastUpdated, message -Last $last | fl  
        } 
    } 
     
    
 
 
   
  
