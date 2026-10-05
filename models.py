from flask_mysqldb import MySQL
import MySQLdb.cursors

mysql = MySQL()

def init_db(app):
    mysql.init_app(app)

#def get_user_by_email(email):
   # cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
   # cur.execute("SELECT * FROM users WHERE email = %s", (email,))
    #user = cur.fetchone()
    #cur.close()
    #return user

def get_user_by_email(email):
    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cur.execute("SELECT * FROM users WHERE email = %s", (email,))
    user = cur.fetchone()
    cur.close()

    print("LOGIN EMAIL:", email)
    print("USER FOUND:", user)

    return user

def create_user(name, email, password, phone):
    cur = mysql.connection.cursor()
    cur.execute(
        "INSERT INTO users (name, email, password, phone) VALUES (%s, %s, %s, %s)",
        (name, email, password, phone)
    )
    mysql.connection.commit()
    user_id = cur.lastrowid
    cur.close()
    return user_id

def get_user_by_id(user_id):
    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cur.execute("SELECT id, name, email, phone FROM users WHERE id = %s", (user_id,))
    user = cur.fetchone()
    cur.close()
    return user

def get_all_destinations():
    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cur.execute("SELECT * FROM destinations")
    destinations = cur.fetchall()
    cur.close()
    return destinations

def get_destination_by_id(dest_id):
    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cur.execute("SELECT * FROM destinations WHERE id = %s", (dest_id,))
    destination = cur.fetchone()
    cur.close()
    return destination

def search_destinations(query):
    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    search = f"%{query}%"
    cur.execute(
        "SELECT * FROM destinations WHERE name LIKE %s OR state LIKE %s OR category LIKE %s",
        (search, search, search)
    )
    destinations = cur.fetchall()
    cur.close()
    return destinations

def get_packages_by_destination(dest_id):
    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cur.execute("SELECT * FROM packages WHERE destination_id = %s", (dest_id,))
    packages = cur.fetchall()
    cur.close()
    return packages

def get_package_by_id(package_id):
    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cur.execute("SELECT * FROM packages WHERE id = %s", (package_id,))
    package = cur.fetchone()
    cur.close()
    return package

def get_all_packages():
    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cur.execute("""
        SELECT p.*, d.name as destination_name, d.state 
        FROM packages p 
        JOIN destinations d ON p.destination_id = d.id
    """)
    packages = cur.fetchall()
    cur.close()
    return packages

def create_booking(user_id, package_id, num_persons, travel_date, total_price):
    cur = mysql.connection.cursor()
    cur.execute(
        """INSERT INTO bookings (user_id, package_id, num_persons, travel_date, total_price) 
           VALUES (%s, %s, %s, %s, %s)""",
        (user_id, package_id, num_persons, travel_date, total_price)
    )
    mysql.connection.commit()
    booking_id = cur.lastrowid
    cur.close()
    return booking_id

def get_user_bookings(user_id):
    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cur.execute("""
        SELECT b.*, p.name as package_name, d.name as destination_name 
        FROM bookings b 
        JOIN packages p ON b.package_id = p.id 
        JOIN destinations d ON p.destination_id = d.id 
        WHERE b.user_id = %s 
        ORDER BY b.created_at DESC
    """, (user_id,))
    bookings = cur.fetchall()
    cur.close()
    return bookings