from flask import Flask, request, jsonify, render_template, send_from_directory
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
import jwt
import datetime
import requests
from functools import wraps
from config import Config
import models
import os

app = Flask(__name__, static_folder='../frontend', static_url_path='')
app.config.from_object(Config)
CORS(app)

# MySQL configuration
app.config['MYSQL_HOST'] = Config.MYSQL_HOST
app.config['MYSQL_USER'] = Config.MYSQL_USER
app.config['MYSQL_PASSWORD'] = Config.MYSQL_PASSWORD
app.config['MYSQL_DB'] = Config.MYSQL_DB
app.config['MYSQL_CURSORCLASS'] = 'DictCursor'

models.init_db(app)

# ==================== Helper Functions ====================

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({'message': 'Token is missing!'}), 401
        try:
            token = token.split(" ")[1]
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=['HS256'])
            current_user = models.get_user_by_id(data['user_id'])
            if not current_user:
                return jsonify({'message': 'Invalid token!'}), 401
        except Exception as e:
            return jsonify({'message': 'Token is invalid!', 'error': str(e)}), 401
        return f(current_user, *args, **kwargs)
    return decorated

# ==================== Routes ====================

@app.route('/')
def index():
    return send_from_directory('../frontend', 'index.html')

# ---------- Auth Routes ----------

@app.route('/api/register', methods=['POST'])
def register():
    try:
        data = request.get_json()
        name = data.get('name')
        email = data.get('email')
        password = data.get('password')
        phone = data.get('phone', '')
        
        if not all([name, email, password]):
            return jsonify({'message': 'All fields are required!'}), 400
        
        if models.get_user_by_email(email):
            return jsonify({'message': 'Email already registered!'}), 409
        
        hashed_password = generate_password_hash(password)
        user_id = models.create_user(name, email, hashed_password, phone)
        
        token = jwt.encode({
            'user_id': user_id,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(days=7)
        }, app.config['SECRET_KEY'], algorithm='HS256')
        
        return jsonify({
            'message': 'Registration successful!',
            'token': token,
            'user': {'id': user_id, 'name': name, 'email': email}
        }), 201
    except Exception as e:
        return jsonify({'message': 'Registration failed!', 'error': str(e)}), 500

@app.route('/api/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')
        
        if not all([email, password]):
            return jsonify({'message': 'Email and password required!'}), 400
        
        user = models.get_user_by_email(email)
        if not user or not check_password_hash(user['password'], password):
            return jsonify({'message': 'Invalid credentials!'}), 401
        
        token = jwt.encode({
            'user_id': user['id'],
            'exp': datetime.datetime.utcnow() + datetime.timedelta(days=7)
        }, app.config['SECRET_KEY'], algorithm='HS256')
        
        return jsonify({
            'message': 'Login successful!',
            'token': token,
            'user': {
                'id': user['id'],
                'name': user['name'],
                'email': user['email'],
                'phone': user.get('phone', '')
            }
        }), 200
    except Exception as e:
        return jsonify({'message': 'Login failed!', 'error': str(e)}), 500

@app.route('/api/profile', methods=['GET'])
@token_required
def profile(current_user):
    return jsonify({'user': current_user}), 200

# ---------- Destination Routes ----------

@app.route('/api/destinations', methods=['GET'])
def get_destinations():
    try:
        query = request.args.get('search', '')
        if query:
            destinations = models.search_destinations(query)
        else:
            destinations = models.get_all_destinations()
        return jsonify({'destinations': destinations}), 200
    except Exception as e:
        return jsonify({'message': 'Failed to fetch destinations', 'error': str(e)}), 500

@app.route('/api/destinations/<int:dest_id>', methods=['GET'])
def get_destination(dest_id):
    try:
        destination = models.get_destination_by_id(dest_id)
        if not destination:
            return jsonify({'message': 'Destination not found'}), 404
        packages = models.get_packages_by_destination(dest_id)
        return jsonify({'destination': destination, 'packages': packages}), 200
    except Exception as e:
        return jsonify({'message': 'Failed to fetch destination', 'error': str(e)}), 500

# ---------- Package Routes ----------

@app.route('/api/packages', methods=['GET'])
def get_packages():
    try:
        packages = models.get_all_packages()
        return jsonify({'packages': packages}), 200
    except Exception as e:
        return jsonify({'message': 'Failed to fetch packages', 'error': str(e)}), 500

# ---------- Booking Routes ----------

@app.route('/api/bookings', methods=['POST'])
@token_required
def create_booking(current_user):
    try:
        data = request.get_json()
        package_id = data.get('package_id')
        num_persons = int(data.get('num_persons', 1))
        travel_date = data.get('travel_date')
        
        package = models.get_package_by_id(package_id)
        if not package:
            return jsonify({'message': 'Package not found'}), 404
        
        if num_persons > package['max_persons']:
            return jsonify({'message': f'Maximum {package["max_persons"]} persons allowed'}), 400
        
        total_price = float(package['price_per_person']) * num_persons
        
        booking_id = models.create_booking(
            current_user['id'], package_id, num_persons, travel_date, total_price
        )
        
        return jsonify({
            'message': 'Booking created successfully!',
            'booking_id': booking_id,
            'total_price': total_price
        }), 201
    except Exception as e:
        return jsonify({'message': 'Booking failed', 'error': str(e)}), 500

@app.route('/api/bookings', methods=['GET'])
@token_required
def get_bookings(current_user):
    try:
        bookings = models.get_user_bookings(current_user['id'])
        return jsonify({'bookings': bookings}), 200
    except Exception as e:
        return jsonify({'message': 'Failed to fetch bookings', 'error': str(e)}), 500

# ---------- Weather Routes ----------

@app.route('/api/weather', methods=['GET'])
def get_weather():
    try:
        lat = request.args.get('lat')
        lon = request.args.get('lon')
        
        if not lat or not lon:
            return jsonify({'message': 'Latitude and longitude required'}), 400
        
        api_key = Config.OPENWEATHER_API_KEY
        
        # Current weather
        current_url = f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={api_key}&units=metric"
        current_res = requests.get(current_url)
        current_data = current_res.json()
        
        # Forecast (5 days / 3 hour)
        forecast_url = f"https://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={api_key}&units=metric"
        forecast_res = requests.get(forecast_url)
        forecast_data = forecast_res.json()
        
        # Process forecast to get daily temps
        daily_forecast = {}
        if 'list' in forecast_data:
            for item in forecast_data['list']:
                date = item['dt_txt'].split(' ')[0]
                if date not in daily_forecast:
                    daily_forecast[date] = {
                        'date': date,
                        'temps': [],
                        'descriptions': [],
                        'icons': []
                    }
                daily_forecast[date]['temps'].append(item['main']['temp'])
                daily_forecast[date]['descriptions'].append(item['weather'][0]['description'])
                daily_forecast[date]['icons'].append(item['weather'][0]['icon'])
        
        forecast_list = []
        for date, info in list(daily_forecast.items())[:5]:
            forecast_list.append({
                'date': date,
                'min_temp': round(min(info['temps']), 1),
                'max_temp': round(max(info['temps']), 1),
                'description': info['descriptions'][0],
                'icon': info['icons'][0]
            })
        
        return jsonify({
            'current': {
                'temp': round(current_data['main']['temp'], 1),
                'feels_like': round(current_data['main']['feels_like'], 1),
                'humidity': current_data['main']['humidity'],
                'description': current_data['weather'][0]['description'],
                'icon': current_data['weather'][0]['icon'],
                'wind_speed': current_data['wind']['speed']
            },
            'forecast': forecast_list
        }), 200
    except Exception as e:
        return jsonify({'message': 'Weather fetch failed', 'error': str(e)}), 500

@app.route('/api/config', methods=['GET'])
def get_config():
    return jsonify({
        'google_maps_api_key': Config.GOOGLE_MAPS_API_KEY
    }), 200

if __name__ == '__main__':
    app.run(debug=True, port=5000)