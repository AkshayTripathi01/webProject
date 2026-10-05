// Weather and Map functionality
let map;

async function loadWeather(lat, lon) {
    const container = document.getElementById('weatherContainer');
    if (!container) return;
    
    try {
        const response = await fetch(`${API_URL}/weather?lat=${lat}&lon=${lon}`);
        const data = await response.json();
        
        if (!response.ok) throw new Error(data.message);
        
        const current = data.current;
        const forecast = data.forecast;
        
        container.innerHTML = `
            <div class="weather-current">
                <div class="temp">${current.temp}°C</div>
                <div class="desc">
                    <img src="https://openweathermap.org/img/wn/${current.icon}@2x.png" style="width:50px;vertical-align:middle;">
                    ${current.description}
                </div>
                <div class="weather-details">
                    <span><i class="fas fa-temperature-low"></i> Feels: ${current.feels_like}°C</span>
                    <span><i class="fas fa-tint"></i> ${current.humidity}%</span>
                    <span><i class="fas fa-wind"></i> ${current.wind_speed} m/s</span>
                </div>
            </div>
            
            <h3 style="margin-top:1.5rem;color:var(--secondary);">5-Day Forecast</h3>
            <div class="forecast-grid" style="margin-top:1rem;">
                ${forecast.map(f => `
                    <div class="forecast-card">
                        <div class="date">${new Date(f.date).toLocaleDateString('en-IN', { weekday: 'short', day: 'numeric', month: 'short' })}</div>
                        <img src="https://openweathermap.org/img/wn/${f.icon}.png" style="width:40px;">
                        <div class="temp">${f.min_temp}° - ${f.max_temp}°</div>
                        <div class="desc">${f.description}</div>
                    </div>
                `).join('')}
            </div>
        `;
    } catch (err) {
        container.innerHTML = `<p style="color:var(--danger);">Weather data unavailable. Please add your OpenWeather API key.</p>`;
    }
}

async function loadMap(lat, lon, name) {
    // Load Google Maps
    try {
        // Fetch API key from backend
        const configRes = await fetch(`${API_URL}/config`);
        const config = await configRes.json();
        const apiKey = config.google_maps_api_key;
        
        if (!apiKey || apiKey === 'your-api-key') {
            document.getElementById('map').innerHTML = `
                <div style="height:100%;display:flex;align-items:center;justify-content:center;background:#eee;text-align:center;padding:1rem;">
                    <p>Add your Google Maps API key in the backend .env file to enable live location</p>
                </div>
            `;
            return;
        }
        
        // Load Google Maps script
        const script = document.createElement('script');
        script.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}&callback=initMap`;
        script.async = true;
        script.defer = true;
        
        window.initMap = function() {
            const location = { lat: parseFloat(lat), lng: parseFloat(lon) };
            
            map = new google.maps.Map(document.getElementById('map'), {
                zoom: 12,
                center: location,
                mapTypeControl: true,
                streetViewControl: true,
                fullscreenControl: true
            });
            
            new google.maps.Marker({
                position: location,
                map: map,
                title: name,
                animation: google.maps.Animation.DROP
            });
            
            // Add info window
            const infoWindow = new google.maps.InfoWindow({
                content: `<div style="padding:0.5rem;"><strong>${name}</strong><br>Lat: ${lat}<br>Lng: ${lon}</div>`
            });
            
            const marker = new google.maps.Marker({
                position: location,
                map: map,
                title: name
            });
            
            marker.addListener('click', () => {
                infoWindow.open(map, marker);
            });
        };
        
        document.head.appendChild(script);
    } catch (err) {
        console.error('Map load error:', err);
    }
}