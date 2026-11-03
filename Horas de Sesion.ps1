# 1. Obtener los eventos del registro de seguridad para los IDs 4624 y 4647
$events = Get-EventLog -LogName Security -InstanceId 4624, 4647 | Sort-Object TimeGenerated

# 2. Agrupar los eventos por día
$groupedByDay = $events | Group-Object { $_.TimeGenerated.ToString("yyyy-MM-dd") }

$results = @()

foreach ($day in $groupedByDay) {
    $dayEvents = $day.Group | Sort-Object TimeGenerated
    
    # Primer evento del día (inicio)
    $firstEvent = $dayEvents[0]
    # Último evento del día (última actividad registrada)
    $lastEvent = $dayEvents[$dayEvents.Length - 1]
    
    # Si hay al menos dos eventos o una diferencia de tiempo válida en el día
    if ($dayEvents.Count -gt 1) {
        $duration = $lastEvent.TimeGenerated - $firstEvent.TimeGenerated
        
        $results += [PSCustomObject]@{
        Fecha      = $day.Name
        PrimerInicio = $firstEvent.TimeGenerated.ToString("HH:mm:ss")
        UltimoRegistro = $lastEvent.TimeGenerated.ToString("HH:mm:ss")
        TotalEventos = $dayEvents.Count
        DuracionEstimada = "$([Math]::Floor($duration.TotalHours)) horas y $($duration.Minutes) minutos"
    }
    } else {
        $results += [PSCustomObject]@{
            Fecha      = $day.Name
            PrimerInicio = $firstEvent.TimeGenerated.ToString("HH:mm:ss")
            UltimoRegistro = "N/A"
            TotalEventos = 1
            DuracionEstimada = "1 solo evento (No computable)"
        }
    }
}

# 3. Mostrar los resultados en una tabla
$results | Format-Table -AutoSize