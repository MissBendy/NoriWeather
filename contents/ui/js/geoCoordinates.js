function obtenerCoordenadas(callback) {
    let url = "http://ip-api.com/json/?fields=lat,lon";

    let req = new XMLHttpRequest();
    req.open("GET", url, true);

    req.onreadystatechange = function () {
        if (req.readyState === 4) {
            if (req.status === 200) {
                try {
                    let datos = JSON.parse(req.responseText);
                    let latitud = datos.lat;
                    let longitud = datos.lon;
                    let full = `${latitud}, ${longitud}`;
                    console.log(`Coordinates obtained: ${full}`);
                    callback(full); // Return full coordinates
                } catch (error) {
                    console.error("Error processing response JSON:", error);
                    callback(null); // Devolver null en caso de error de parsing
                }
            } else {
                console.error(`Request error: ${req.status}`);
                callback(null); // Return null in case of parsing error
            }
        }
    };

    req.onerror = function () {
        console.error("Network error while trying to obtain coordinates.");
        callback(null); // Return null in case of network error
    };

    req.send();
}
