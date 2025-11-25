// Retrieves the user's approximate geographic coordinates using their IP address
function obtainCoordinates(callback) {
    // API endpoint that returns latitude and longitude based on IP
    let url = "http://ip-api.com/json/?fields=lat,lon";
    // console.log("Coordiantes API URL: ", url);

    // Create an asynchronous HTTP request
    let req = new XMLHttpRequest();
    req.open("GET", url, true); // true = async request

    // Handle the request's state changes
    req.onreadystatechange = function () {
        // Only proceed once the request is complete
        if (req.readyState === 4) {
            // 200 = success
            if (req.status === 200) {
                try {
                    // Parse the JSON response
                    let data = JSON.parse(req.responseText);
                    let latitud = data.lat;  // Extract latitude
                    let longitud = data.lon; // Extract longitude

                    // Combine values into a readable string
                    let full = `${latitud}, ${longitud}`;
                    console.log(`Coordinates obtained: ${full}`);

                    // Pass coordinates back through the callback
                    callback(full);
                } catch (error) {
                    // Handle malformed or unexpected JSON responses
                    console.error("Error processing response JSON:", error);
                    callback(null); // Return null on parsing failure
                }
            } else {
                // Handle HTTP errors
                console.error(`Request error: ${req.status}`);
                callback(null); // Return null on failed request
            }
        }
    };

    // Handle network-level failures (no connection, DNS, etc.)
    req.onerror = function () {
        console.error("Network error while trying to obtain coordinates.");
        callback(null);
    };

    // Send the HTTP request
    req.send();
}
