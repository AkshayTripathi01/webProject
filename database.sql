CREATE DATABASE IF NOT EXISTS travel_db;
USE travel_db;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Destinations table
CREATE TABLE IF NOT EXISTS destinations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    description TEXT,
    hidden_places TEXT,
    best_season VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    image_url VARCHAR(500),
    category VARCHAR(50)
);

-- Packages table
CREATE TABLE IF NOT EXISTS packages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    destination_id INT,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price_per_person DECIMAL(10, 2),
    duration_days INT,
    max_persons INT,
    includes TEXT,
    FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE CASCADE
);

-- Bookings table
CREATE TABLE IF NOT EXISTS bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    package_id INT,
    num_persons INT,
    travel_date DATE,
    total_price DECIMAL(10, 2),
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE
);

-- Insert 30 Indian destinations
INSERT INTO destinations (name, state, description, hidden_places, best_season, latitude, longitude, image_url, category) VALUES
('Taj Mahal', 'Uttar Pradesh', 'One of the Seven Wonders of the World, an ivory-white marble mausoleum on the south bank of the Yamuna river.', 'Mehtab Bagh, Chini ka Rauza, Itimad-ud-Daulah Tomb', 'October to March', 27.1751, 78.0421, 'https://images.unsplash.com/photo-1564507592333-c60657eea523', 'Heritage'),
('Jaipur', 'Rajasthan', 'The Pink City known for its majestic palaces, forts and vibrant culture.', 'Panna Meena ka Kund, Patrika Gate, Galtaji Temple', 'October to March', 26.9124, 75.7873, 'https://images.unsplash.com/photo-1477587458883-47145ed94245', 'Heritage'),
('Goa', 'Goa', 'Famous for its beaches, Portuguese heritage, and vibrant nightlife.', 'Butterfly Beach, Netravali Bubble Lake, Cabo de Rama Fort', 'November to February', 15.2993, 74.1240, 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2', 'Beach'),
('Kerala Backwaters', 'Kerala', 'Serene network of lagoons, lakes and canals parallel to the Arabian Sea.', 'Kumbalangi Village, Munroe Island, Pathiramanal Island', 'September to March', 9.4981, 76.3388, 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944', 'Nature'),
('Ladakh', 'Jammu & Kashmir', 'High-altitude desert known for its stunning landscapes and Buddhist culture.', 'Tso Moriri, Hanle Village, Chumathang Hot Springs', 'June to September', 34.1526, 77.5770, 'https://images.unsplash.com/photo-1581793745862-99fde7fa73d2', 'Adventure'),
('Varanasi', 'Uttar Pradesh', 'One of the oldest living cities in the world, spiritual capital of India.', 'Ramnagar Fort, Sarnath, Manikarnika Ghat', 'October to March', 25.3176, 82.9739, 'https://images.unsplash.com/photo-1561361513-2d000a50f0dc', 'Spiritual'),
('Andaman Islands', 'Andaman & Nicobar', 'Pristine beaches, coral reefs and tropical rainforests.', 'Ross Island, Neil Island, Barren Island', 'October to May', 11.7401, 92.6586, 'https://images.unsplash.com/photo-1589308078059-be1415eab4c3', 'Beach'),
('Rishikesh', 'Uttarakhand', 'Yoga capital of the world, located on the banks of Ganges.', 'Neelkanth Mahadev, Kunjapuri Temple, Vashishta Gufa', 'September to April', 30.0869, 78.2676, 'https://images.unsplash.com/photo-1591018653368-9a3a5a8c7f8e', 'Adventure'),
('Udaipur', 'Rajasthan', 'City of Lakes known for its royal palaces and romantic atmosphere.', 'Sajjangarh Monsoon Palace, Badi Lake, Shilpgram', 'September to March', 24.5854, 73.7125, 'https://images.unsplash.com/photo-1587295656906-9d5f4a7d6a8b', 'Heritage'),
('Munnar', 'Kerala', 'Hill station known for tea plantations and scenic beauty.', 'Top Station, Chokramudi Peak, Anamudi', 'September to May', 10.0889, 77.0595, 'https://images.unsplash.com/photo-1600271886742-f049cd451bba', 'Nature'),
('Darjeeling', 'West Bengal', 'Queen of Hills known for tea gardens and toy train.', 'Sandakphu, Tonglu, Lepchajagat', 'March to May, October to November', 27.0360, 88.2627, 'https://images.unsplash.com/photo-1544413660-299165566b1d', 'Nature'),
('Hampi', 'Karnataka', 'Ancient village with ruins of Vijayanagara Empire.', 'Matanga Hill, Anegundi, Sanapur Lake', 'October to February', 15.3350, 76.4600, 'https://images.unsplash.com/photo-1609920658906-8223bd289001', 'Heritage'),
('Mysore', 'Karnataka', 'City of Palaces known for its royal heritage.', 'Chamundi Hills, Srirangapatna, Brindavan Gardens', 'October to March', 12.2958, 76.6394, 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220', 'Heritage'),
('Shillong', 'Meghalaya', 'Scotland of the East, known for its scenic beauty.', 'Mawlynnong, Dawki, Laitlum Canyons', 'September to May', 25.5788, 91.8933, 'https://images.unsplash.com/photo-1597074866923-dc0589150358', 'Nature'),
('Ranthambore', 'Rajasthan', 'Famous tiger reserve and national park.', 'Kachida Valley, Surwal Lake, Padam Talao', 'October to April', 26.0173, 76.5026, 'https://images.unsplash.com/photo-1615963244664-5b845b2025ee', 'Wildlife'),
('Coorg', 'Karnataka', 'Scotland of India, known for coffee plantations.', 'Mandalpatti, Abbey Falls, Talakaveri', 'October to March', 12.3375, 75.8069, 'https://images.unsplash.com/photo-1590766940554-52b4b8e4b4b8', 'Nature'),
('Pondicherry', 'Tamil Nadu', 'French colonial heritage and serene beaches.', 'Paradise Beach, Auroville, Serenity Beach', 'October to March', 11.9416, 79.8083, 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220', 'Beach'),
('Agra Fort', 'Uttar Pradesh', 'UNESCO World Heritage Site, Mughal architecture.', 'Jama Masjid, Kinari Bazaar, Mehtab Bagh', 'October to March', 27.1795, 78.0211, 'https://images.unsplash.com/photo-1585135497273-1a86b09fe70e', 'Heritage'),
('Kodaikanal', 'Tamil Nadu', 'Princess of Hill Stations, known for its misty mountains.', 'Dolphin Nose, Coaker\'s Walk, Berijam Lake', 'April to June, September to October', 10.2381, 77.4892, 'https://images.unsplash.com/photo-1580881647059-923632b8fd75', 'Nature'),
('Pushkar', 'Rajasthan', 'Holy city with the only Brahma Temple in the world.', 'Savitri Temple, Rangji Temple, Pushkar Lake', 'October to March', 26.4899, 74.5511, 'https://images.unsplash.com/photo-1590050752117-238cb0fb12b1', 'Spiritual'),
('Alleppey', 'Kerala', 'Venice of the East, famous for houseboat cruises.', 'Marari Beach, Krishnapuram Palace, Pathiramanal', 'September to March', 9.4981, 76.3388, 'https://images.unsplash.com/photo-1593693397690-362cb9666fc2', 'Nature'),
('Khajuraho', 'Madhya Pradesh', 'UNESCO site known for erotic sculptures.', 'Raneh Falls, Panna National Park, Benisagar Lake', 'October to March', 24.8318, 79.9199, 'https://images.unsplash.com/photo-1609920658906-8223bd289001', 'Heritage'),
('Jim Corbett', 'Uttarakhand', 'India\'s oldest national park, famous for tigers.', 'Corbett Falls, Garjiya Temple, Kalagarh Dam', 'November to June', 29.5300, 78.7747, 'https://images.unsplash.com/photo-1615963244664-5b845b2025ee', 'Wildlife'),
('Gokarna', 'Karnataka', 'Serene beach town with temple heritage.', 'Om Beach, Half Moon Beach, Paradise Beach', 'October to February', 14.5479, 74.3188, 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2', 'Beach'),
('Leh', 'Jammu & Kashmir', 'Gateway to Ladakh, known for Buddhist monasteries.', 'Pangong Lake, Nubra Valley, Magnetic Hill', 'May to September', 34.1526, 77.5770, 'https://images.unsplash.com/photo-1581793745862-99fde7fa73d2', 'Adventure'),
('Ooty', 'Tamil Nadu', 'Queen of Hill Stations, known for tea gardens.', 'Doddabetta Peak, Pykara Falls, Avalanche Lake', 'April to June, September to November', 11.4102, 76.6950, 'https://images.unsplash.com/photo-1580881647059-923632b8fd75', 'Nature'),
('Ajanta Ellora', 'Maharashtra', 'Ancient rock-cut caves, UNESCO World Heritage.', 'Bibi ka Maqbara, Daulatabad Fort, Aurangabad Caves', 'October to March', 20.0269, 75.1799, 'https://images.unsplash.com/photo-1609920658906-8223bd289001', 'Heritage'),
('Sundarbans', 'West Bengal', 'Largest mangrove forest, home to Royal Bengal Tigers.', 'Sajnekhali, Dobanki, Netidhopani', 'November to February', 21.9497, 88.9380, 'https://images.unsplash.com/photo-1615963244664-5b845b2025ee', 'Wildlife'),
('Valley of Flowers', 'Uttarakhand', 'UNESCO site with alpine flowers and meadows.', 'Hemkund Sahib, Govindghat, Ghangaria', 'July to September', 30.7280, 79.6050, 'https://images.unsplash.com/photo-1590766940554-52b4b8e4b4b8', 'Nature'),
('Kanyakumari', 'Tamil Nadu', 'Southernmost tip of India, meeting point of three seas.', 'Vivekananda Rock, Thiruvalluvar Statue, Padmanabhapuram Palace', 'October to March', 8.0883, 77.5385, 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220', 'Beach');

-- Insert packages for each destination
INSERT INTO packages (destination_id, name, description, price_per_person, duration_days, max_persons, includes) VALUES
(1, 'Taj Mahal Day Tour', 'Explore the majestic Taj Mahal and nearby monuments', 2500.00, 1, 15, 'Guide, Entry tickets, Lunch'),
(1, 'Agra Heritage Package', 'Complete Agra experience with Taj, Fort and Fatehpur Sikri', 6500.00, 2, 10, 'Hotel, Guide, Transport, Meals'),
(2, 'Jaipur Royal Tour', 'Experience the royal heritage of Pink City', 5500.00, 3, 12, 'Hotel, Guide, Transport, Breakfast'),
(2, 'Rajasthan Grand Tour', 'Jaipur, Udaipur, Jodhpur comprehensive tour', 25000.00, 7, 8, 'Hotel, Guide, Transport, All meals'),
(3, 'Goa Beach Package', 'Relax on the beautiful beaches of Goa', 8000.00, 3, 20, 'Hotel, Transport, Breakfast'),
(3, 'Goa Adventure Package', 'Water sports and beach hopping', 12000.00, 4, 15, 'Hotel, Activities, Meals'),
(4, 'Kerala Backwater Cruise', 'Overnight houseboat experience', 7000.00, 2, 12, 'Houseboat, Meals, Guide'),
(4, 'Kerala Complete', 'Backwaters, Munnar, Thekkady tour', 18000.00, 6, 10, 'Hotel, Transport, Meals, Guide'),
(5, 'Ladakh Bike Trip', 'Adventure bike tour through Ladakh', 35000.00, 8, 10, 'Bike, Fuel, Stay, Meals'),
(5, 'Ladakh Exploration', 'Complete Ladakh experience', 28000.00, 7, 12, 'Hotel, Transport, Guide, Meals'),
(6, 'Varanasi Spiritual Tour', 'Experience the spiritual essence of Varanasi', 4500.00, 2, 15, 'Hotel, Guide, Boat ride'),
(6, 'Varanasi-Sarnath Package', 'Complete spiritual journey', 7500.00, 3, 12, 'Hotel, Guide, Transport, Meals'),
(7, 'Andaman Beach Paradise', 'Pristine beaches and water activities', 25000.00, 5, 15, 'Hotel, Ferry, Activities'),
(7, 'Andaman Honeymoon', 'Romantic getaway in Andaman', 35000.00, 6, 2, 'Resort, Ferry, Candlelight dinner'),
(8, 'Rishikesh Rafting Package', 'White water rafting adventure', 3500.00, 2, 20, 'Camp, Rafting, Meals'),
(8, 'Rishikesh Yoga Retreat', 'Yoga and meditation retreat', 8000.00, 5, 15, 'Ashram, Yoga sessions, Meals'),
(9, 'Udaipur Romantic Getaway', 'Romantic tour of City of Lakes', 12000.00, 3, 2, 'Hotel, Boat ride, Dinner'),
(9, 'Udaipur Royal Experience', 'Palace stay and heritage tour', 20000.00, 4, 10, 'Palace hotel, Guide, Transport'),
(10, 'Munnar Tea Garden Tour', 'Explore tea plantations and hills', 6000.00, 3, 15, 'Hotel, Guide, Transport'),
(10, 'Munnar Adventure', 'Trekking and nature exploration', 9000.00, 4, 12, 'Hotel, Trek, Meals'),
(11, 'Darjeeling Toy Train', 'Heritage toy train experience', 5000.00, 3, 15, 'Hotel, Train tickets, Guide'),
(11, 'Darjeeling Trek', 'Trek to Sandakphu', 12000.00, 5, 10, 'Tea house, Guide, Meals'),
(12, 'Hampi Heritage Tour', 'Explore Vijayanagara ruins', 4000.00, 2, 15, 'Hotel, Guide, Transport'),
(12, 'Hampi-Badami Package', 'Complete heritage tour', 8000.00, 4, 12, 'Hotel, Guide, Transport, Meals'),
(13, 'Mysore Palace Tour', 'Royal Mysore experience', 4500.00, 2, 15, 'Hotel, Guide, Transport'),
(13, 'Mysore-Coorg Package', 'Palaces and hills combined', 12000.00, 5, 12, 'Hotel, Transport, Meals'),
(14, 'Shillong Cherrapunji Tour', 'Explore Meghalaya beauty', 8000.00, 4, 15, 'Hotel, Transport, Guide'),
(14, 'Meghalaya Living Roots', 'Unique living root bridges trek', 15000.00, 6, 10, 'Homestay, Guide, Meals'),
(15, 'Ranthambore Tiger Safari', 'Wildlife safari experience', 7000.00, 2, 12, 'Resort, Safari, Meals'),
(15, 'Ranthambore Weekend', 'Complete wildlife getaway', 12000.00, 3, 10, 'Resort, Safaris, Meals'),
(16, 'Coorg Coffee Trail', 'Coffee plantation experience', 6500.00, 3, 15, 'Homestay, Guide, Meals'),
(16, 'Coorg Nature Escape', 'Waterfalls and nature tour', 9000.00, 4, 12, 'Resort, Transport, Meals'),
(17, 'Pondicherry French Quarter', 'French colonial heritage walk', 5500.00, 3, 15, 'Hotel, Guide, Transport'),
(17, 'Pondicherry Beach Package', 'Beach and Auroville experience', 8000.00, 4, 12, 'Resort, Transport, Meals'),
(18, 'Agra Fort Tour', 'Mughal architecture exploration', 3000.00, 1, 20, 'Guide, Entry tickets, Lunch'),
(18, 'Agra Complete', 'Taj, Fort and Fatehpur Sikri', 7000.00, 2, 15, 'Hotel, Guide, Transport, Meals'),
(19, 'Kodaikanal Hill Escape', 'Misty mountains and lakes', 5000.00, 3, 15, 'Hotel, Transport, Breakfast'),
(19, 'Kodaikanal Adventure', 'Trekking and camping', 8000.00, 4, 12, 'Camp, Trek, Meals'),
(20, 'Pushkar Holy Tour', 'Spiritual journey to Pushkar', 4000.00, 2, 15, 'Hotel, Guide, Transport'),
(20, 'Pushkar Camel Fair', 'Experience the famous camel fair', 6000.00, 3, 20, 'Camp, Guide, Meals'),
(21, 'Alleppey Houseboat', 'Overnight houseboat cruise', 6000.00, 2, 12, 'Houseboat, Meals, Guide'),
(21, 'Alleppey Beach Package', 'Beach and backwater combo', 9000.00, 4, 15, 'Resort, Houseboat, Meals'),
(22, 'Khajuraho Temple Tour', 'Ancient temple exploration', 4500.00, 2, 15, 'Hotel, Guide, Transport'),
(22, 'Khajuraho Wildlife', 'Temples and Panna National Park', 9000.00, 4, 12, 'Hotel, Safari, Meals'),
(23, 'Jim Corbett Safari', 'Tiger safari experience', 8000.00, 2, 15, 'Resort, Safari, Meals'),
(23, 'Corbett Weekend Getaway', 'Complete wildlife package', 14000.00, 3, 12, 'Resort, Safaris, Meals'),
(24, 'Gokarna Beach Hopping', 'Explore serene beaches', 4000.00, 3, 15, 'Hotel, Transport, Breakfast'),
(24, 'Gokarna Temple Tour', 'Spiritual and beach experience', 6000.00, 4, 12, 'Hotel, Guide, Transport'),
(25, 'Leh Monastery Tour', 'Buddhist monastery exploration', 15000.00, 5, 12, 'Hotel, Transport, Guide'),
(25, 'Leh Adventure Package', 'Trekking and rafting', 22000.00, 7, 10, 'Hotel, Activities, Meals'),
(26, 'Ooty Toy Train', 'Heritage train experience', 4500.00, 3, 15, 'Hotel, Train, Guide'),
(26, 'Ooty Nature Tour', 'Gardens and lakes exploration', 6000.00, 4, 12, 'Hotel, Transport, Meals'),
(27, 'Ajanta Ellora Caves', 'Ancient cave exploration', 5500.00, 3, 15, 'Hotel, Guide, Transport'),
(27, 'Aurangabad Heritage', 'Complete heritage package', 9000.00, 4, 12, 'Hotel, Guide, Transport, Meals'),
(28, 'Sundarbans Wildlife', 'Mangrove forest safari', 8000.00, 3, 12, 'Boat, Guide, Meals'),
(28, 'Sundarbans Adventure', 'Complete wildlife experience', 12000.00, 4, 10, 'Boat, Resort, Meals, Guide'),
(29, 'Valley of Flowers Trek', 'Alpine flowers trek', 12000.00, 6, 15, 'Camp, Guide, Meals'),
(29, 'Hemkund Sahib Yatra', 'Spiritual trek to Hemkund', 10000.00, 5, 20, 'Camp, Guide, Meals'),
(30, 'Kanyakumari Day Tour', 'Southern tip exploration', 3000.00, 1, 20, 'Guide, Transport, Lunch'),
(30, 'Kanyakumari Complete', 'Full southern experience', 7000.00, 3, 15, 'Hotel, Guide, Transport, Meals');