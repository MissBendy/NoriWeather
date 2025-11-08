function GetForecastWeather(latitud, longitud, startDate, endDate, callback) {
    let url = `https://api.open-meteo.com/v1/forecast?latitude=${latitud}&longitude=${longitud}&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto&start_date=${startDate}&end_date=${endDate}&models=ecmwf_ifs025`;

    let req = new XMLHttpRequest();
    req.open("GET", url, true);

    req.onreadystatechange = function () {
        if (req.readyState === 4) {
            if (req.status === 200) {
                let data = JSON.parse(req.responseText);

                let daily = data.daily;
                let codes = daily.weather_code.join(' ');
                let max = daily.temperature_2m_max.join(' ');
                let min = daily.temperature_2m_min.join(' ');

                let full = codes + " " + max + " " + min;
                console.log(full);
                callback(full);
            } else {
                console.error(`Error in the request: ${req.status}`);
            }
        }
    };

    req.send();
}
