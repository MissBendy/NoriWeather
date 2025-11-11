// Fetches detailed weather data (current, next 5-hourly, and 7-day daily forecast) from the Open-Meteo API
function getWeatherData(latitud, longitud, hours, callback) {
    // Calculate start and end dates for a 7-day forecast
    const start = new Date();
    const end = new Date();
    end.setDate(start.getDate() + 6); // 7 days including today

    const startDate = start.toISOString().split('T')[0];
    const endDate = end.toISOString().split('T')[0];

    // Build the API request URL
    let url = `https://api.open-meteo.com/v1/forecast?latitude=${latitud}&longitude=${longitud}&current=temperature_2m,weather_code&hourly=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto&start_date=${startDate}&end_date=${endDate}&models=ecmwf_ifs025`;

    // Current local hour
    const now = new Date();
    const hoursC = now.getHours();
    const minutes = now.getMinutes();
    const currentTime = (minutes === 0) ? hoursC : (hoursC + 1) % 24;

    let req = new XMLHttpRequest();
    req.open("GET", url, true);

    req.onreadystatechange = function () {
        if (req.readyState === 4) {
            if (req.status === 200) {
                let data = JSON.parse(req.responseText);

                // Current weather
                let currents = data.current;
                let temperaturaActual = currents.temperature_2m;
                let codeCurrentWeather = currents.weather_code;

                // Daily forecast: all 7 days
                let daily = data.daily;
                let tempMins = daily.temperature_2m_min.join(' ');
                let tempMaxs = daily.temperature_2m_max.join(' ');
                let dailyCodes = daily.weather_code.join(' ');

                // Hourly forecast: current hour + next 4 hours
                let hourly = data.hourly;
                let hourlyTemps = [];
                let hourlyCodes = [];
                for (let i = 0; i < 5; i++) {
                    let idx = (currentTime + i) % 24;
                    hourlyTemps.push(hourly.temperature_2m[idx]);
                    hourlyCodes.push(hourly.weather_code[idx]);
                }
                let hourlyWeather = hourlyTemps.join(' ');
                let hourlyWeatherCodes = hourlyCodes.join(' ');

                // Combine all data into a single string for callback use
                let full = temperaturaActual + " " + tempMins + " " + tempMaxs + " " + codeCurrentWeather + " " + hourlyWeather + " " + hourlyWeatherCodes + " " + dailyCodes;

                // Print the combined string first
                //console.log("=== Combined Full String ===");
                //console.log(full);

                // Labeled console output for clarity
                //console.log("\n=== Current Weather ===");
                //console.log("Temperature:", temperaturaActual);
                //console.log("Weather Code:", codeCurrentWeather);

                //console.log("\n=== Next 5 Hourly Forecasts ===");
                //console.log("Temperatures:", hourlyWeather);
                //console.log("Weather Codes:", hourlyWeatherCodes);

                //console.log("\n=== 7-Day Daily Forecast ===");
                //console.log("Min Temperatures:", tempMins);
                //console.log("Max Temperatures:", tempMaxs);
                //console.log("Weather Codes:", dailyCodes);

                callback(full);
            } else {
                console.error(`Error in request: weathergeneral ${req.status}`);
            }
        }
    };

    req.send();
}
