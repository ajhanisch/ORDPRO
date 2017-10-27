function Present-Outcome()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)][ValidateSet("GO", "NOGO")] $outcome
    )

$success =
@"


::::    ::::  :::    :::  ::::::::  :::    :::       ::::::::  :::    :::  ::::::::   ::::::::  :::::::::: ::::::::   ::::::::  
+:+:+: :+:+:+ :+:    :+: :+:    :+: :+:    :+:      :+:    :+: :+:    :+: :+:    :+: :+:    :+: :+:       :+:    :+: :+:    :+: 
+:+ +:+:+ +:+ +:+    +:+ +:+        +:+    +:+      +:+        +:+    +:+ +:+        +:+        +:+       +:+        +:+        
+#+  +:+  +#+ +#+    +:+ +#+        +#++:++#++      +#++:++#++ +#+    +:+ +#+        +#+        +#++:++#  +#++:++#++ +#++:++#++ 
+#+       +#+ +#+    +#+ +#+        +#+    +#+             +#+ +#+    +#+ +#+        +#+        +#+              +#+        +#+ 
#+#       #+# #+#    #+# #+#    #+# #+#    #+#      #+#    #+# #+#    #+# #+#    #+# #+#    #+# #+#       #+#    #+# #+#    #+# 
###       ###  ########   ########  ###    ###       ########   ########   ########   ########  ########## ########   ########  


"@

$fail = 
@"


::::::::::: :::::::::  :::   :::      :::    :::     :::     :::::::::  :::::::::  :::::::::: :::::::::  
    :+:     :+:    :+: :+:   :+:      :+:    :+:   :+: :+:   :+:    :+: :+:    :+: :+:        :+:    :+: 
    +:+     +:+    +:+  +:+ +:+       +:+    +:+  +:+   +:+  +:+    +:+ +:+    +:+ +:+        +:+    +:+ 
    +#+     +#++:++#:    +#++:        +#++:++#++ +#++:++#++: +#++:++#:  +#+    +:+ +#++:++#   +#++:++#:  
    +#+     +#+    +#+    +#+         +#+    +#+ +#+     +#+ +#+    +#+ +#+    +#+ +#+        +#+    +#+ 
    #+#     #+#    #+#    #+#         #+#    #+# #+#     #+# #+#    #+# #+#    #+# #+#        #+#    #+# 
    ###     ###    ###    ###         ###    ### ###     ### ###    ### #########  ########## ###    ### 


"@

    if($outcome -eq 'GO')
    {
        Write-Log -log_file $($log_file) -message "VICTORY"

        foreach ($line in $success -split "`n")
        {
            foreach ($char in $line.tochararray())
            {
                if ($([int]$char) -le 9580 -and  $([int]$char) -ge 9552)
                {
                    Write-Host -ForegroundColor Black $char -NoNewline
                }
                else
                {
                    Write-Host -ForegroundColor Green $char -NoNewline
                }
            }
            write-host ""
        }
    }
    elseif($outcome -eq 'NOGO')
    {
        Write-Log -level '[ERROR]' -log_file $($log_file) -message "FAILURE"

        foreach ($line in $fail -split "`n")
        {
            foreach ($char in $line.tochararray())
            {
                if ($([int]$char) -le 9580 -and  $([int]$char) -ge 9552)
                {
                    Write-Host -ForegroundColor Red $char -NoNewline
                }
                else
                {
                    Write-Host -ForegroundColor White $char -NoNewline
                }
            }
            write-host ""
        }
    }
}