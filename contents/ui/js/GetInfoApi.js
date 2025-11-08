function getWeatherData(latitud, longitud, startDate, endDate, hours, callback) {
    let url = `https://api.open-meteo.com/v1/forecast?latitude=${latitud}&longitude=${longitud}&hourly=temperature_2m,weather_code&current=temperature_2m,is_day,weather_code,wind_speed_10m&hourly=uv_index&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=auto&start_date=${startDate}&end_date=${(endDate)}&models=ecmwf_ifs025`;

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
                let data = JSON.parse(req.responseText);
                let currents = data.current;
                let isday = currents.is_day;

                let temperaturaActual = currents.temperature_2m;
                let windSpeed = currents.wind_speed_10m;
                let codeCurrentWeather = currents.weather_code;

                let daily = data.daily;
                let currentPrecipProbability = daily.precipitation_probability_max[0];

                let hourly = data.hourly
                let probabilityUVindex = hourly.uv_index[hours];

                let tempForecastHourlyOne = hourly.temperature_2m[currentTime];
                let tempForecastHourlyTwo = hourly.temperature_2m[(currentTime + 1) % 24];
                let tempForecastHourlyThree = hourly.temperature_2m[(currentTime + 2) % 24];
                let tempForecastHourlyFour = hourly.temperature_2m[(currentTime + 3) % 24];
                let tempForecastHourlyFive = hourly.temperature_2m[(currentTime + 4) % 24];

                let hourlyWeather = tempForecastHourlyOne + " " + tempForecastHourlyTwo + " " + tempForecastHourlyThree + " " + tempForecastHourlyFour + " " + tempForecastHourlyFive

                let codeForecastHourlyOne = hourly.weather_code[currentTime];
                let codeForecastHourlyTwo = hourly.weather_code[(currentTime + 1) % 24];
                let codeForecastHourlyThree = hourly.weather_code[(currentTime + 2) % 24];
                let codeForecastHourlyFour = hourly.weather_code[(currentTime + 3) % 24];
                let codeForecastHourlyFive = hourly.weather_code[(currentTime + 4) % 24];

                let hourlyWeatherCodes = codeForecastHourlyOne + " " + codeForecastHourlyTwo + " " + codeForecastHourlyThree + " " + codeForecastHourlyFour + " " + codeForecastHourlyFive

                let tempMin = daily.temperature_2m_min[0];
                let tempMax = daily.temperature_2m_max[0];

                let full = temperaturaActual + " " + tempMin + " " + tempMax + " " + codeCurrentWeather + " " + currentPrecipProbability + " " + windSpeed + " " + probabilityUVindex + " " + isday + " " + hourlyWeather + " " + hourlyWeatherCodes
                console.log(`${full}`);
                callback(full);
                console.log(`https://api.open-meteo.com/v1/forecast?latitude=${latitud}&longitude=${longitud}&hourly=temperature_2m,weather_code&current=temperature_2m,is_day,weather_code,wind_speed_10m&hourly=uv_index&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=auto&start_date=${startDate}&end_date=${startDate}`)
            } else {
                console.error(`Error in request: weathergeneral ${req.status}`);
                //callback(`failed ${req.status}`)
            }
        }
    };

    req.send();
}
