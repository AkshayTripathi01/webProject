const API_URL = 'http://localhost:5000/api';

// ==================== Auth Helpers ====================

function getToken() {
    return localStorage.getItem('token');
}

function getUser() {
    const user = localStorage.getItem('user');
    return user ? JSON.parse(user) : null;
}

function isLoggedIn() {
    return !!getToken();
}

function logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    window.location.href = 'index.html';
}

// Update navbar based on auth state
function updateNavbar() {
    const authLinks = document.getElementById('authLinks');
    const userLinks = document.getElementById('userLinks');
    const userName = document.getElementById('userName');
    
    if (isLoggedIn() && getUser()) {
        if (authLinks) authLinks.style.display = 'none';
        if (userLinks) userLinks.style.display = 'block';
        if (userName) userName.textContent = `Hi, ${getUser().name}`;
    } else {
        if (authLinks) authLinks.style.display = 'block';
        if (userLinks) userLinks.style.display = 'none';
    }
    
    const logoutBtn = document.getElementById('logoutBtn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', (e) => {
            e.preventDefault();
            logout();
        });
    }
}

// ==================== API Helpers ====================

async function apiCall(endpoint, options = {}) {
    const headers = {
        'Content-Type': 'application/json',
        ...options.headers
    };
    
    if (isLoggedIn()) {
        headers['Authorization'] = `Bearer ${getToken()}`;
    }
    
    const response = await fetch(`${API_URL}${endpoint}`, {
        ...options,
        headers
    });
    
    const data = await response.json();
    if (!response.ok) {
        throw new Error(data.message || 'Something went wrong');
    }
    return data;
}

// ==================== Destinations ====================

async function loadPopularDestinations() {
    const container = document.getElementById('popularDestinations');
    if (!container) return;
    
    try {
        const data = await apiCall('/destinations');
        const popular = data.destinations.slice(0, 6);
        container.innerHTML = popular.map(d => createDestinationCard(d)).join('');
    } catch (err) {
        container.innerHTML = `<p class="error">Failed to load destinations</p>`;
    }
}

async function loadAllDestinations() {
    const container = document.getElementById('allDestinations');
    if (!container) return;
    
    try {
        const data = await apiCall('/destinations');
        renderDestinations(data.destinations);
    } catch (err) {
        container.innerHTML = `<p class="error">Failed to load destinations</p>`;
    }
}

function renderDestinations(destinations) {
    const container = document.getElementById('allDestinations');
    if (!container) return;
    
    if (destinations.length === 0) {
        container.innerHTML = '<p style="text-align:center;grid-column:1/-1;">No destinations found</p>';
        return;
    }
    
    container.innerHTML = destinations.map(d => createDestinationCard(d)).join('');
}

function createDestinationCard(d) {
    return `
        <div class="destination-card" onclick="window.location.href='destination-detail.html?id=${d.id}'">
            <img src="${d.image_url}" alt="${d.name}" onerror="this.src='https://via.placeholder.com/400x220?text=${encodeURIComponent(d.name)}'">
            <div class="destination-info">
                <h3>${d.name}</h3>
                <p class="state"><i class="fas fa-map-marker-alt"></i> ${d.state}</p>
                <span class="category">${d.category}</span>
                <p class="season"><i class="fas fa-calendar-alt"></i> Best: ${d.best_season}</p>
                <button class="btn-primary">View Details</button>
            </div>
        </div>
    `;
}

function searchFromHero() {
    const query = document.getElementById('heroSearch').value.trim();
    window.location.href = `destinations.html?search=${encodeURIComponent(query)}`;
}

async function filterDestinations() {
    const search = document.getElementById('searchInput').value.trim();
    const category = document.getElementById('categoryFilter').value;
    
    try {
        const data = await apiCall(`/destinations?search=${encodeURIComponent(search)}`);
        let destinations = data.destinations;
        if (category) {
            destinations = destinations.filter(d => d.category === category);
        }
        renderDestinations(destinations);
    } catch (err) {
        console.error(err);
    }
}

// ==================== Destination Detail ====================

async function loadDestinationDetail(destId) {
    const container = document.getElementById('destinationDetail');
    if (!container) return;
    
    try {
        const data = await apiCall(`/destinations/${destId}`);
        const d = data.destination;
        const packages = data.packages;
        
        container.innerHTML = `
            <div class="detail-hero" style="background-image: url('${d.image_url}')">
                <div class="detail-hero-content">
                    <h1>${d.name}</h1>
                    <p><i class="fas fa-map-marker-alt"></i> ${d.state} | <i class="fas fa-tag"></i> ${d.category}</p>
                </div>
            </div>
            
            <div class="detail-container">
                <div>
                    <div class="detail-section">
                        <h2><i class="fas fa-info-circle"></i> About</h2>
                        <p>${d.description}</p>
                    </div>
                    
                    <div class="detail-section">
                        <h2><i class="fas fa-gem"></i> Hidden Places</h2>
                        <ul class="hidden-places-list">
                            ${d.hidden_places.split(',').map(p => `<li><i class="fas fa-star"></i> ${p.trim()}</li>`).join('')}
                        </ul>
                    </div>
                    
                    <div class="detail-section">
                        <h2><i class="fas fa-calendar-alt"></i> Best Season to Visit</h2>
                        <p style="font-size:1.1rem;color:var(--success);font-weight:600;">
                            <i class="fas fa-sun"></i> ${d.best_season}
                        </p>
                    </div>
                    
                    <div class="detail-section">
                        <h2><i class="fas fa-box"></i> Available Packages</h2>
                        <div class="packages-grid" style="padding:0;">
                            ${packages.length ? packages.map(p => createPackageCard(p, d.name)).join('') : '<p>No packages available</p>'}
                        </div>
                    </div>
                </div>
                
                <div>
                    <div class="detail-section">
                        <h2><i class="fas fa-cloud-sun"></i> Weather</h2>
                        <div id="weatherContainer">
                            <p>Loading weather...</p>
                        </div>
                    </div>
                    
                    <div class="detail-section">
                        <h2><i class="fas fa-map"></i> Live Location</h2>
                        <div id="map"></div>
                        <p style="margin-top:0.5rem;font-size:0.85rem;color:var(--gray);">
                            <i class="fas fa-crosshairs"></i> Lat: ${d.latitude}, Lng: ${d.longitude}
                        </p>
                    </div>
                </div>
            </div>
        `;
        
        // Load weather
        loadWeather(d.latitude, d.longitude);
        
        // Load map
        loadMap(d.latitude, d.longitude, d.name);
        
    } catch (err) {
        container.innerHTML = `<p style="text-align:center;padding:3rem;">Failed to load destination</p>`;
    }
}

function createPackageCard(p, destName = '') {
    return `
        <div class="package-card">
            <h3>${p.name}</h3>
            ${destName ? `<p class="dest"><i class="fas fa-map-marker-alt"></i> ${destName}</p>` : ''}
            <p>${p.description}</p>
            <div class="package-meta">
                <span><i class="fas fa-clock"></i> ${p.duration_days} Days</span>
                <span><i class="fas fa-users"></i> Max ${p.max_persons}</span>
            </div>
            <div class="package-includes">
                <strong>Includes:</strong> ${p.includes}
            </div>
            <div class="price">₹${parseFloat(p.price_per_person).toLocaleString()} <small>/person</small></div>
            <button class="btn-primary btn-full" onclick="openBookingModal(${p.id}, '${p.name.replace(/'/g, "\\'")}', ${p.price_per_person})">
                <i class="fas fa-bookmark"></i> Book Now
            </button>
        </div>
    `;
}

// ==================== Packages ====================

async function loadAllPackages() {
    const container = document.getElementById('allPackages');
    if (!container) return;
    
    try {
        const data = await apiCall('/packages');
        renderPackages(data.packages);
    } catch (err) {
        container.innerHTML = `<p class="error">Failed to load packages</p>`;
    }
}

function renderPackages(packages) {
    const container = document.getElementById('allPackages');
    if (!container) return;
    
    container.innerHTML = packages.map(p => `
        <div class="package-card">
            <h3>${p.name}</h3>
            <p class="dest"><i class="fas fa-map-marker-alt"></i> ${p.destination_name}, ${p.state}</p>
            <p>${p.description}</p>
            <div class="package-meta">
                <span><i class="fas fa-clock"></i> ${p.duration_days} Days</span>
                <span><i class="fas fa-users"></i> Max ${p.max_persons} persons</span>
            </div>
            <div class="package-includes">
                <strong>Includes:</strong> ${p.includes}
            </div>
            <div class="price">₹${parseFloat(p.price_per_person).toLocaleString()} <small>/person</small></div>
            <button class="btn-primary btn-full" onclick="openBookingModal(${p.id}, '${p.name.replace(/'/g, "\\'")}', ${p.price_per_person})">
                <i class="fas fa-bookmark"></i> Book Now
            </button>
        </div>
    `).join('');
}

async function filterPackages() {
    const query = document.getElementById('packageSearch').value.toLowerCase();
    try {
        const data = await apiCall('/packages');
        const filtered = data.packages.filter(p => 
            p.name.toLowerCase().includes(query) || 
            p.destination_name.toLowerCase().includes(query)
        );
        renderPackages(filtered);
    } catch (err) {
        console.error(err);
    }
}

// ==================== Booking Modal ====================

function openBookingModal(packageId, packageName, pricePerPerson) {
    if (!isLoggedIn()) {
        alert('Please login to book a package');
        window.location.href = 'login.html';
        return;
    }
    
    const modal = document.getElementById('bookingModal');
    if (!modal) return;
    
    document.getElementById('bookPackageId').value = packageId;
    document.getElementById('bookPackageName').value = packageName;
    document.getElementById('bookNumPersons').value = 1;
    document.getElementById('bookNumPersons').dataset.price = pricePerPerson;
    updateTotalPrice();
    
    // Set min date to tomorrow
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    document.getElementById('bookTravelDate').min = tomorrow.toISOString().split('T')[0];
    
    modal.classList.add('active');
}

function closeBookingModal() {
    document.getElementById('bookingModal').classList.remove('active');
}

function updateTotalPrice() {
    const numPersons = parseInt(document.getElementById('bookNumPersons').value) || 1;
    const price = parseFloat(document.getElementById('bookNumPersons').dataset.price) || 0;
    document.getElementById('bookTotalPrice').value = `₹${(numPersons * price).toLocaleString()}`;
}

// Setup booking form
document.addEventListener('DOMContentLoaded', () => {
    updateNavbar();
    
    const numPersonsInput = document.getElementById('bookNumPersons');
    if (numPersonsInput) {
        numPersonsInput.addEventListener('input', updateTotalPrice);
    }
    
    const bookingForm = document.getElementById('bookingForm');
    if (bookingForm) {
        bookingForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const msgDiv = document.getElementById('bookingMessage');
            
            try {
                const data = await apiCall('/bookings', {
                    method: 'POST',
                    body: JSON.stringify({
                        package_id: parseInt(document.getElementById('bookPackageId').value),
                        num_persons: parseInt(document.getElementById('bookNumPersons').value),
                        travel_date: document.getElementById('bookTravelDate').value
                    })
                });
                
                msgDiv.className = 'message success';
                msgDiv.textContent = `Booking confirmed! Booking ID: ${data.booking_id}, Total: ₹${data.total_price.toLocaleString()}`;
                
                setTimeout(() => {
                    closeBookingModal();
                    msgDiv.className = 'message';
                }, 3000);
            } catch (err) {
                msgDiv.className = 'message error';
                msgDiv.textContent = err.message;
            }
        });
    }
});

// Close modal on outside click
document.addEventListener('click', (e) => {
    const modal = document.getElementById('bookingModal');
    if (modal && e.target === modal) {
        closeBookingModal();
    }
});

// Check URL params for search
document.addEventListener('DOMContentLoaded', () => {
    const params = new URLSearchParams(window.location.search);
    const search = params.get('search');
    if (search && document.getElementById('searchInput')) {
        document.getElementById('searchInput').value = search;
        filterDestinations();
    }
});