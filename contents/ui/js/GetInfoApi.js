function obtenerDatosClimaticos(latitud, longitud, fechaInicio, fechaFin, hours, callback) {
    let url = `https://api.open-meteo.com/v1/forecast?latitude=${latitud}&longitude=${longitud}&hourly=temperature_2m,weather_code&current=temperature_2m,is_day,weather_code,wind_speed_10m&hourly=uv_index&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=auto&start_date=${fechaInicio}&end_date=${(fechaFin)}&models=ecmwf_ifs025`;

    const now = new Date();
    const hoursC = now.getHours(); // Hours (0-23)
    const minutes = now.getMinutes(); // Minutes (0-59)
    // Match QML logic: jump 1 hour ahead if minutes != 0
    const currentTime = (minutes === 0) ? hoursC : (hoursC + 1) % 24;

    let req = new XMLHttpRequest();
    req.open("GET", url, true);

    req.onreadystatechange = function () {
        if (req.readyState === 4) {
            if (req.status === 200) {
                let datos = JSON.parse(req.responseText);
                let currents = datos.current;
                let isday = currents.is_day;

                let temperaturaActual = currents.temperature_2m;
                let windSpeed = currents.wind_speed_10m;
                let codeCurrentWeather = currents.weather_code;

                let datosDiarios = datos.daily;
                let propabilityPrecipitationCurrent = datosDiarios.precipitation_probability_max[0];

                let hourly = datos.hourly
                let propabilityUVindex = hourly.uv_index[hours];

                let tempForecastHorylOne = hourly.temperature_2m[currentTime];
                let tempForecastHorylTwo = hourly.temperature_2m[(currentTime + 1) % 24];
                let tempForecastHorylThree = hourly.temperature_2m[(currentTime + 2) % 24];
                let tempForecastHorylFour = hourly.temperature_2m[(currentTime + 3) % 24];
                let tempForecastHorylFive = hourly.temperature_2m[(currentTime + 4) % 24];

                let hoursWether = tempForecastHorylOne + " " + tempForecastHorylTwo + " " + tempForecastHorylThree + " " + tempForecastHorylFour + " " + tempForecastHorylFive

                let codeForecastHorylOne = hourly.weather_code[currentTime];
                let codeForecastHorylTwo = hourly.weather_code[(currentTime + 1) % 24];
                let codeForecastHorylThree = hourly.weather_code[(currentTime + 2) % 24];
                let codeForecastHorylFour = hourly.weather_code[(currentTime + 3) % 24];
                let codeForecastHorylFive = hourly.weather_code[(currentTime + 4) % 24];

                let weather_codeWether = codeForecastHorylOne + " " + codeForecastHorylTwo + " " + codeForecastHorylThree + " " + codeForecastHorylFour + " " + codeForecastHorylFive

                let tempMin = datosDiarios.temperature_2m_min[0];
                let tempMax = datosDiarios.temperature_2m_max[0];

                let full = temperaturaActual + " " + tempMin + " " + tempMax + " " + codeCurrentWeather + " " + propabilityPrecipitationCurrent + " " + windSpeed + " " + propabilityUVindex + " " + isday + " " + hoursWether + " " + weather_codeWether
                console.log(`${full}`);
                callback(full);
                console.log(`https://api.open-meteo.com/v1/forecast?latitude=${latitud}&longitude=${longitud}&hourly=temperature_2m,weather_code&current=temperature_2m,is_day,weather_code,wind_speed_10m&hourly=uv_index&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=auto&start_date=${fechaInicio}&end_date=${fechaInicio}`)
            } else {
                console.error(`Error in request: weathergeneral ${req.status}`);
                //callback(`failed ${req.status}`)
            }
        }
    };

    req.send();
}
