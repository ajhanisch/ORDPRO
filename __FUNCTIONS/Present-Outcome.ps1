function Present-Outcome()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)][ValidateSet("GO", "NOGO")] $outcome
    )

$go_1 =
@"


::::    ::::  :::    :::  ::::::::  :::    :::       ::::::::  :::    :::  ::::::::   ::::::::  :::::::::: ::::::::   ::::::::  
+:+:+: :+:+:+ :+:    :+: :+:    :+: :+:    :+:      :+:    :+: :+:    :+: :+:    :+: :+:    :+: :+:       :+:    :+: :+:    :+: 
+:+ +:+:+ +:+ +:+    +:+ +:+        +:+    +:+      +:+        +:+    +:+ +:+        +:+        +:+       +:+        +:+        
+#+  +:+  +#+ +#+    +:+ +#+        +#++:++#++      +#++:++#++ +#+    +:+ +#+        +#+        +#++:++#  +#++:++#++ +#++:++#++ 
+#+       +#+ +#+    +#+ +#+        +#+    +#+             +#+ +#+    +#+ +#+        +#+        +#+              +#+        +#+ 
#+#       #+# #+#    #+# #+#    #+# #+#    #+#      #+#    #+# #+#    #+# #+#    #+# #+#    #+# #+#       #+#    #+# #+#    #+# 
###       ###  ########   ########  ###    ###       ########   ########   ########   ########  ########## ########   ########  


"@

$go_2 = 
@"

 ____ ____ ____ _________ ____ ____ ____ 
||Y |||O |||U |||       |||W |||I |||N ||
||__|||__|||__|||_______|||__|||__|||__||
|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|

"@

$go_3 = 
@"

 __    __  _____   __  __      __      __  ______   __  __     
/\ \  /\ \/\  __`\/\ \/\ \    /\ \  __/\ \/\__  _\ /\ \/\ \    
\ `\`\\/'/\ \ \/\ \ \ \ \ \   \ \ \/\ \ \ \/_/\ \/ \ \ `\\ \   
 `\ `\ /'  \ \ \ \ \ \ \ \ \   \ \ \ \ \ \ \ \ \ \  \ \ , ` \  
   `\ \ \   \ \ \_\ \ \ \_\ \   \ \ \_/ \_\ \ \_\ \__\ \ \`\ \ 
     \ \_\   \ \_____\ \_____\   \ `\___x___/ /\_____\\ \_\ \_\
      \/_/    \/_____/\/_____/    '\/__//__/  \/_____/ \/_/\/_/
                                                               
                                                               

"@

$go_4 = 
@"
 _______ _______ _______     _______ _______ _______ 
|\     /|\     /|\     /|   |\     /|\     /|\     /|
| +---+ | +---+ | +---+ |   | +---+ | +---+ | +---+ |
| |   | | |   | | |   | |   | |   | | |   | | |   | |
| |Y  | | |O  | | |U  | |   | |W  | | |I  | | |N  | |
| +---+ | +---+ | +---+ |   | +---+ | +---+ | +---+ |
|/_____\|/_____\|/_____\|   |/_____\|/_____\|/_____\|           
"@


$go_5 = 
@"
.-.-. .-.-. .-.-.      .-.-. .-.-. .-.-.  
'. Y )'. O )'. U ).-.-.'. W )'. I )'. N ) 
  ).'   ).'   ).' '._.'  ).'   ).'   ).'  
"@


$go_6 = 
@"

                                                                                                                  
`8.`8888.      ,8'  ,o888888o.     8 8888      88           `8.`888b                 ,8'  8 8888 b.             8 
 `8.`8888.    ,8'. 8888     `88.   8 8888      88            `8.`888b               ,8'   8 8888 888o.          8 
  `8.`8888.  ,8',8 8888       `8b  8 8888      88             `8.`888b             ,8'    8 8888 Y88888o.       8 
   `8.`8888.,8' 88 8888        `8b 8 8888      88              `8.`888b     .b    ,8'     8 8888 .`Y888888o.    8 
    `8.`88888'  88 8888         88 8 8888      88               `8.`888b    88b  ,8'      8 8888 8o. `Y888888o. 8 
     `8. 8888   88 8888         88 8 8888      88                `8.`888b .`888b,8'       8 8888 8`Y8o. `Y88888o8 
      `8 8888   88 8888        ,8P 8 8888      88                 `8.`888b8.`8888'        8 8888 8   `Y8o. `Y8888 
       8 8888   `8 8888       ,8P  ` 8888     ,8P                  `8.`888`8.`88'         8 8888 8      `Y8o. `Y8 
       8 8888    ` 8888     ,88'     8888   ,d8P                    `8.`8' `8,`'          8 8888 8         `Y8o.` 
       8 8888       `8888888P'        `Y88888P'                      `8.`   `8'           8 8888 8            `Yo 

"@

$go_7 = 
@"

01011001 01001111 01010101  01010111 01001001 01001110 

"@

$go_8 = 
@"

   _     _      _     _      _     _       _     _      _     _      _     _   
  (c).-.(c)    (c).-.(c)    (c).-.(c)     (c).-.(c)    (c).-.(c)    (c).-.(c)  
   / ._. \      / ._. \      / ._. \       / ._. \      / ._. \      / ._. \   
 __\( Y )/__  __\( Y )/__  __\( Y )/__   __\( Y )/__  __\( Y )/__  __\( Y )/__ 
(_.-/'-'\-._)(_.-/'-'\-._)(_.-/'-'\-._) (_.-/'-'\-._)(_.-/'-'\-._)(_.-/'-'\-._)
   || Y ||      || O ||      || U ||       || W ||      || I ||      || N ||   
 _.' `-' '._  _.' `-' '._  _.' `-' '._   _.' `-' '._  _.' `-' '._  _.' `-' '._ 
(.-./`-'\.-.)(.-./`-'\.-.)(.-./`-'\.-.) (.-./`-'\.-.)(.-./`-'\.-.)(.-./`-'\.-.)
 `-'     `-'  `-'     `-'  `-'     `-'   `-'     `-'  `-'     `-'  `-'     `-' 

"@

$go_9 = 
@"

▓██   ██▓ ▒█████   █    ██     █     █░ ██▓ ███▄    █ 
 ▒██  ██▒▒██▒  ██▒ ██  ▓██▒   ▓█░ █ ░█░▓██▒ ██ ▀█   █ 
  ▒██ ██░▒██░  ██▒▓██  ▒██░   ▒█░ █ ░█ ▒██▒▓██  ▀█ ██▒
  ░ ▐██▓░▒██   ██░▓▓█  ░██░   ░█░ █ ░█ ░██░▓██▒  ▐▌██▒
  ░ ██▒▓░░ ████▓▒░▒▒█████▓    ░░██▒██▓ ░██░▒██░   ▓██░
   ██▒▒▒ ░ ▒░▒░▒░ ░▒▓▒ ▒ ▒    ░ ▓░▒ ▒  ░▓  ░ ▒░   ▒ ▒ 
 ▓██ ░▒░   ░ ▒ ▒░ ░░▒░ ░ ░      ▒ ░ ░   ▒ ░░ ░░   ░ ▒░
 ▒ ▒ ░░  ░ ░ ░ ▒   ░░░ ░ ░      ░   ░   ▒ ░   ░   ░ ░ 
 ░ ░         ░ ░     ░            ░     ░           ░ 
 ░ ░                                                  

"@

$go_10 = 
@"

 __   __   ___    _   _          __      __ ___    _  _   
 \ \ / /  / _ \  | | | |    o O O\ \    / /|_ _|  | \| |  
  \ V /  | (_) | | |_| |   o      \ \/\/ /  | |   | .` |  
  _|_|_   \___/   \___/   TS__[O]  \_/\_/  |___|  |_|\_|  
_| """ |_|"""""|_|"""""| {======|_|"""""|_|"""""|_|"""""| 
"`-0-0-'"`-0-0-'"`-0-0-'./o--000'"`-0-0-'"`-0-0-'"`-0-0-' 

"@

$nogo_1 = 
@"


::::::::::: :::::::::  :::   :::      :::    :::     :::     :::::::::  :::::::::  :::::::::: :::::::::  
    :+:     :+:    :+: :+:   :+:      :+:    :+:   :+: :+:   :+:    :+: :+:    :+: :+:        :+:    :+: 
    +:+     +:+    +:+  +:+ +:+       +:+    +:+  +:+   +:+  +:+    +:+ +:+    +:+ +:+        +:+    +:+ 
    +#+     +#++:++#:    +#++:        +#++:++#++ +#++:++#++: +#++:++#:  +#+    +:+ +#++:++#   +#++:++#:  
    +#+     +#+    +#+    +#+         +#+    +#+ +#+     +#+ +#+    +#+ +#+    +#+ +#+        +#+    +#+ 
    #+#     #+#    #+#    #+#         #+#    #+# #+#     #+# #+#    #+# #+#    #+# #+#        #+#    #+# 
    ###     ###    ###    ###         ###    ### ###     ### ###    ### #########  ########## ###    ### 


"@

$nogo_2 =
@"

 ____ ____ ____ _________ ____ ____ ____ ____ 
||Y |||O |||U |||       |||L |||O |||S |||E ||
||__|||__|||__|||_______|||__|||__|||__|||__||
|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|

"@

$nogo_3 = 
@"

 __    __  _____   __  __      __       _____   ____    ____      
/\ \  /\ \/\  __`\/\ \/\ \    /\ \     /\  __`\/\  _`\ /\  _`\    
\ `\`\\/'/\ \ \/\ \ \ \ \ \   \ \ \    \ \ \/\ \ \,\L\_\ \ \L\_\  
 `\ `\ /'  \ \ \ \ \ \ \ \ \   \ \ \  __\ \ \ \ \/_\__ \\ \  _\L  
   `\ \ \   \ \ \_\ \ \ \_\ \   \ \ \L\ \\ \ \_\ \/\ \L\ \ \ \L\ \
     \ \_\   \ \_____\ \_____\   \ \____/ \ \_____\ `\____\ \____/
      \/_/    \/_____/\/_____/    \/___/   \/_____/\/_____/\/___/ 
                                                                  
                                                                  

"@

$nogo_4 = 
@"

                                                             
 _______ _______ _______     _______ _______ _______ _______ 
|\     /|\     /|\     /|   |\     /|\     /|\     /|\     /|
| +---+ | +---+ | +---+ |   | +---+ | +---+ | +---+ | +---+ |
| |   | | |   | | |   | |   | |   | | |   | | |   | | |   | |
| |Y  | | |O  | | |U  | |   | |L  | | |O  | | |S  | | |E  | |
| +---+ | +---+ | +---+ |   | +---+ | +---+ | +---+ | +---+ |
|/_____\|/_____\|/_____\|   |/_____\|/_____\|/_____\|/_____\|
                                                             

"@

$nogo_5 = 
@"

.-.-. .-.-. .-.-.      .-.-. .-.-. .-.-. .-.-.  
'. Y )'. O )'. U ).-.-.'. L )'. O )'. S )'. E ) 
  ).'   ).'   ).' '._.'  ).'   ).'   ).'   ).'  
                                                

"@

$nogo_6 = 
@"

                                                                                                                       
`8.`8888.      ,8'  ,o888888o.     8 8888      88           8 8888         ,o888888o.       d888888o.   8 8888888888   
 `8.`8888.    ,8'. 8888     `88.   8 8888      88           8 8888      . 8888     `88.   .`8888:' `88. 8 8888         
  `8.`8888.  ,8',8 8888       `8b  8 8888      88           8 8888     ,8 8888       `8b  8.`8888.   Y8 8 8888         
   `8.`8888.,8' 88 8888        `8b 8 8888      88           8 8888     88 8888        `8b `8.`8888.     8 8888         
    `8.`88888'  88 8888         88 8 8888      88           8 8888     88 8888         88  `8.`8888.    8 888888888888 
     `8. 8888   88 8888         88 8 8888      88           8 8888     88 8888         88   `8.`8888.   8 8888         
      `8 8888   88 8888        ,8P 8 8888      88           8 8888     88 8888        ,8P    `8.`8888.  8 8888         
       8 8888   `8 8888       ,8P  ` 8888     ,8P           8 8888     `8 8888       ,8P 8b   `8.`8888. 8 8888         
       8 8888    ` 8888     ,88'     8888   ,d8P            8 8888      ` 8888     ,88'  `8b.  ;8.`8888 8 8888         
       8 8888       `8888888P'        `Y88888P'             8 888888888888 `8888888P'     `Y8888P ,88P' 8 888888888888 

"@

$nogo_7 = 
@"

01011001 01001111 01010101  01001100 01001111 01010011 01000101 

"@

$nogo_8 = 
@"

   _     _      _     _      _     _       _     _      _     _      _     _      _     _   
  (c).-.(c)    (c).-.(c)    (c).-.(c)     (c).-.(c)    (c).-.(c)    (c).-.(c)    (c).-.(c)  
   / ._. \      / ._. \      / ._. \       / ._. \      / ._. \      / ._. \      / ._. \   
 __\( Y )/__  __\( Y )/__  __\( Y )/__   __\( Y )/__  __\( Y )/__  __\( Y )/__  __\( Y )/__ 
(_.-/'-'\-._)(_.-/'-'\-._)(_.-/'-'\-._) (_.-/'-'\-._)(_.-/'-'\-._)(_.-/'-'\-._)(_.-/'-'\-._)
   || Y ||      || O ||      || U ||       || L ||      || O ||      || S ||      || E ||   
 _.' `-' '._  _.' `-' '._  _.' `-' '._   _.' `-' '._  _.' `-' '._  _.' `-' '._  _.' `-' '._ 
(.-./`-'\.-.)(.-./`-'\.-.)(.-./`-'\.-.) (.-./`-'\.-.)(.-./`-'\.-.)(.-./`-`\.-.)(.-./`-'\.-.)
 `-'     `-'  `-'     `-'  `-'     `-'   `-'     `-'  `-'     `-'  `-'     `-'  `-'     `-' 

"@

$nogo_9 = 
@"

▓██   ██▓ ▒█████   █    ██     ██▓     ▒█████    ██████ ▓█████ 
 ▒██  ██▒▒██▒  ██▒ ██  ▓██▒   ▓██▒    ▒██▒  ██▒▒██    ▒ ▓█   ▀ 
  ▒██ ██░▒██░  ██▒▓██  ▒██░   ▒██░    ▒██░  ██▒░ ▓██▄   ▒███   
  ░ ▐██▓░▒██   ██░▓▓█  ░██░   ▒██░    ▒██   ██░  ▒   ██▒▒▓█  ▄ 
  ░ ██▒▓░░ ████▓▒░▒▒█████▓    ░██████▒░ ████▓▒░▒██████▒▒░▒████▒
   ██▒▒▒ ░ ▒░▒░▒░ ░▒▓▒ ▒ ▒    ░ ▒░▓  ░░ ▒░▒░▒░ ▒ ▒▓▒ ▒ ░░░ ▒░ ░
 ▓██ ░▒░   ░ ▒ ▒░ ░░▒░ ░ ░    ░ ░ ▒  ░  ░ ▒ ▒░ ░ ░▒  ░ ░ ░ ░  ░
 ▒ ▒ ░░  ░ ░ ░ ▒   ░░░ ░ ░      ░ ░   ░ ░ ░ ▒  ░  ░  ░     ░   
 ░ ░         ░ ░     ░            ░  ░    ░ ░        ░     ░  ░
 ░ ░                                                           

"@

$nogo_10 = 
@"

 __   __   ___    _   _             _       ___     ___     ___   
 \ \ / /  / _ \  | | | |    o O O  | |     / _ \   / __|   | __|  
  \ V /  | (_) | | |_| |   o       | |__  | (_) |  \__ \   | _|   
  _|_|_   \___/   \___/   TS__[O]  |____|  \___/   |___/   |___|  
_| """ |_|"""""|_|"""""| {======|_|"""""|_|"""""|_|"""""|_|"""""| 
"`-0-0-'"`-0-0-'"`-0-0-'./o--000'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-' 

"@

    if($outcome -eq 'GO')
    {
        Write-Log -log_file $($log_file) -message "VICTORY"

        $go_outcome = 1..10 | Get-Random -Count 1
        switch($go_outcome)
        {
            1
            {
                foreach ($line in $($go_1) -split "`n")
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
            
            2
            {
                foreach ($line in $($go_2) -split "`n")
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
            
            3
            {
                foreach ($line in $($go_3) -split "`n")
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
            
            4
            {
                foreach ($line in $($go_4) -split "`n")
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

            5
            {
                foreach ($line in $($go_5) -split "`n")
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

            6
            {
                foreach ($line in $($go_6) -split "`n")
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

            7
            {
                foreach ($line in $($go_7) -split "`n")
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

            8
            {
                foreach ($line in $($go_8) -split "`n")
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

            9
            {
                foreach ($line in $($go_9) -split "`n")
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

            10
            {
                foreach ($line in $($go_10) -split "`n")
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
        }
    }
    elseif($outcome -eq 'NOGO')
    {
        Write-Log -level '[ERROR]' -log_file $($log_file) -message "FAILURE"

        $nogo_outcome = 1..10 | Get-Random -Count 1
        switch($nogo_outcome)
        {
            1
            {
                foreach ($line in $($nogo_1) -split "`n")
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
            
            2
            {
                foreach ($line in $($nogo_2) -split "`n")
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
            
            3
            {
                foreach ($line in $($nogo_3) -split "`n")
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
            
            4
            {
                foreach ($line in $($nogo_4) -split "`n")
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

            5
            {
                foreach ($line in $($nogo_5) -split "`n")
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

            6
            {
                foreach ($line in $($nogo_6) -split "`n")
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

            7
            {
                foreach ($line in $($nogo_7) -split "`n")
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

            8
            {
                foreach ($line in $($nogo_8) -split "`n")
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

            9
            {
                foreach ($line in $($nogo_9) -split "`n")
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

            10
            {
                foreach ($line in $($nogo_10) -split "`n")
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
        }

        foreach ($line in $nogo_outcome -split "`n")
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