// Fetches detailed weather data (current, next 5-hourly, and 7-day daily forecast) from the Open-Meteo API
function getWeatherData(latitud, longitud, hours, model, callback) {
    // Calculate start and end dates for a 7-day forecast
    const start = new Date();
    const end = new Date();
    end.setDate(start.getDate() + 6); // 7 days including today

    // Convert dates to ISO string format for the API
    // const startDate = start.toISOString().split('T')[0];
    // const endDate = end.toISOString().split('T')[0];

    // Build the API request URL
    let url = `https://api.open-meteo.com/v1/forecast?latitude=${latitud}&longitude=${longitud}&current=temperature_2m,weather_code&hourly=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto&models=${model}`;
    // console.log("Weather API URL:", url);

    // Create a new XMLHttpRequest
    let req = new XMLHttpRequest();
    req.open("GET", url, true);

    req.onreadystatechange = function () {
        if (req.readyState === 4) { // Request completed
            if (req.status === 200) { // Request successful
                let data = JSON.parse(req.responseText);

                // Current Weather
                let currents = data.current;
                let temperaturaActual = currents.temperature_2m; // Current temperature
                let codeCurrentWeather = currents.weather_code; // Current weather code

                // Daily Forecast
                let daily = data.daily;
                let tempMins = daily.temperature_2m_min.join(' '); // Min temps for 7 days
                let tempMaxs = daily.temperature_2m_max.join(' ');// Max temps for 7 days
                let dailyCodes = daily.weather_code.join(' ');   // Weather codes for 7 days

                // Hourly Forecast
                let hourly = data.hourly;

                const now = new Date();
                const currentHour = now.getHours();

                // Find the index in hourly.time that matches the current local hour
                let nowIndex = hourly.time.findIndex(t => new Date(t).getHours() === currentHour);
                if (nowIndex === -1) nowIndex = 0; // fallback if not found

                let hourlyTemps = [];
                let hourlyCodes = [];

                // Get next 5 hours (skipping current hour)
                for (let i = 1; i <= 5; i++) {
                    let idx = (nowIndex + i) % hourly.temperature_2m.length; // wrap around if index exceeds array length
                    hourlyTemps.push(hourly.temperature_2m[idx]);
                    hourlyCodes.push(hourly.weather_code[idx]);
                }

                // Convert hourly arrays to space-separated strings
                let hourlyWeather = hourlyTemps.join(' ');
                let hourlyWeatherCodes = hourlyCodes.join(' ');

                // Combine all data into a single string to pass to callback
                let full = temperaturaActual + " " + tempMins + " " + tempMaxs + " " + codeCurrentWeather + " " + hourlyWeather + " " + hourlyWeatherCodes + " " + dailyCodes;

                //console.log("--- Combined Full String ---");
                //console.log(full);

                //console.log("--- Current Weather ---");
                //console.log("Temperature:", temperaturaActual);
                //console.log("Weather Code:", codeCurrentWeather);

                //console.log("--- Next 5 Hourly Forecasts ---");
                //console.log("Temperatures:", hourlyWeather);
                //console.log("Weather Codes:", hourlyWeatherCodes);

                //console.log("--- 7-Day Daily Forecast ---");
                //console.log("Min Temperatures:", tempMins);
                //console.log("Max Temperatures:", tempMaxs);
                //console.log("Weather Codes:", dailyCodes);

                // Execute callback with the full combined string
                callback(full);
            } else {
                console.error(`Error in request: weathergeneral ${req.status}`);
            }
        }
    };

    // Send the request
    req.send();
}
