function getNameCity(latitude, longitud, language, callback) {
    let url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitud}&accept-language=${language}`;
    console.log("Generated URL: ", url); // To verify the generated URL

    let req = new XMLHttpRequest();
    req.open("GET", url, true);

    req.onreadystatechange = function () {
        if (req.readyState === 4) {
            if (req.status === 200) {
                try {
                    let data = JSON.parse(req.responseText);
                    let address = data.address;
                    let city = address.city;
                    let county = address.county;
                    let state = address.state;
                    let full = city ? city : state ? state : county;
                    console.log(full);
                    callback(full);
                } catch (e) {
                    console.error("Error parsing the response JSON: ", e);
                }
            } else {
                console.error(`city failed`);
            }
        }
    };

    req.onerror = function () {
        console.error("The request failed");
    };

    req.ontimeout = function () {
        console.error("The request exceeded the waiting time");
    };

    req.send();
}

