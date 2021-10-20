
import os, time, pickle, configparser, datetime, PIL.Image, shutil
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from threading import Timer

# remove old & create cache folder
if os.path.exists('cache'):
	shutil.rmtree('cache')
os.mkdir("cache")
os.mkdir(r"cache\\progress")
open(r"cache\\progress\\Initializing...", "x")

# Force exit handler
StopCheckForForceExit = True
def CheckForForceExit():
	global driver, StopCheckForForceExit
	if os.path.exists(r"cache\\stop"):
		# close Firefox and kill this script
		try:
			driver.close()
		except:
			print("Force exit without ending the driver. Firefox will remain at background process!")
		open(r"cache\\done", "x")
		os._exit(0)
	if not StopCheckForForceExit:
		Timer(0.5, CheckForForceExit).start()

def ConfigParserGet(config, Section, Key):
	value = ''
	try:
		value = config[Section][Key]
	except:
		pass
	return value

#	Setting-up config
DefaultConfig = configparser.ConfigParser()
DefaultConfig['Setting'] = {}
DefaultConfig['Setting']['FirefoxPath'] = r"C:\\Program Files\\Mozilla Firefox\\firefox.exe"
DefaultConfig['Setting']['FirefoxDriverPath'] = r"Data\\BrowserDriver\\geckodriver-v0.29.0-win64\\geckodriver.exe"
DefaultConfig['Setting']['CookiesPath'] = r"cookies_firefox.dat"
DefaultConfig['Setting']['BrowserTimeout'] = r"30"

Config = configparser.ConfigParser()
Config['Setting'] = {}
Config['UserData'] = {}
if os.path.exists(r"Data\\User\\config.ini"):
	Config.read(r"Data\\User\\config.ini")
#FirefoxPath
if not os.path.exists(ConfigParserGet(Config, 'Setting', 'FirefoxPath')):
	Config['Setting']['FirefoxPath'] = ConfigParserGet(DefaultConfig, 'Setting', 'FirefoxPath')
while not os.path.exists(ConfigParserGet(Config, 'Setting', 'FirefoxPath')):
	Config['Setting']['FirefoxPath'] = input("Please input valid Firefox path: ")
#FirefoxDriverPath
if not os.path.exists(ConfigParserGet(Config, 'Setting', 'FirefoxDriverPath')):
	Config['Setting']['FirefoxDriverPath'] = ConfigParserGet(DefaultConfig, 'Setting', 'FirefoxDriverPath')
while not os.path.exists(ConfigParserGet(Config, 'Setting', 'FirefoxDriverPath')):
	Config['Setting']['FirefoxDriverPath'] = input("Please input valid Firefox driver path: ")
#CookiesPath
if not ConfigParserGet(Config, 'Setting', 'CookiesPath'):
	Config['Setting']['CookiesPath'] = ConfigParserGet(DefaultConfig, 'Setting', 'CookiesPath')
#BrowserTimeout
if not ConfigParserGet(Config, 'Setting', 'BrowserTimeout'):
	Config['Setting']['BrowserTimeout'] = ConfigParserGet(DefaultConfig, 'Setting', 'BrowserTimeout')
#Save Config
with open(r"Data\\User\\config.ini", 'w') as configFile:
	Config.write(configFile)
print("Config saved")

#	some browser settings/options
options = webdriver.FirefoxOptions()
options.binary_location = Config['Setting']['FirefoxPath']
profiles = webdriver.FirefoxProfile()
profiles.set_preference('app.update.auto', False)
profiles.set_preference('app.update.enabled', False)
driverPath = Config['Setting']['FirefoxDriverPath']
options.add_argument("--headless")

#	configure pageLoadStrategy to interactive (not complete loaded webpage; don't wait webpage to load)
Capabilities = DesiredCapabilities.FIREFOX
Capabilities["pageLoadStrategy"] = "eager"

# check for force exit before start Firefox
CheckForForceExit()
#   initialize browser
open(r"cache\\progress\\Starting up Firefox...", "x")
print("Initializing...")
driver = webdriver.Firefox(desired_capabilities=Capabilities, options=options, executable_path=driverPath, firefox_profile=profiles)
driver.set_page_load_timeout(int(ConfigParserGet(Config, 'Setting', 'BrowserTimeout')))
open(r"cache\\progress\\Firefox ready", "x")
# first, settle up driver, later make it able to force stop
StopCheckForForceExit = False
CheckForForceExit()

def LoadCookie(Domain, CookiePath):
	#	navigate (don't load)
	try:
		driver.get(Domain)
	except:
		pass
	while True:
		#	load cookie
		try:
			cookies = pickle.load(open(CookiePath, "rb"))
			for cookie in cookies:
				driver.add_cookie(cookie)
		except:
			continue
		else:
			break


if os.path.exists(Config['Setting']['CookiesPath']):
	open(r"cache\\progress\\Loading cookies...", "x")
	print("Loading cookie...")
	LoadCookie('https://shopee.com/', Config['Setting']['CookiesPath'])
	open(r"cache\\progress\\Cookies Loaded", "x")
	print("Cookie Loaded!")

time.sleep(1)
#   navigate and load
LoadErr = 0
while True:
	try:
		driver.get("https://shopee.com/shopee-coins/")
		break
	except:
		LoadErr += 1
		time.sleep(3)
	if LoadErr == 1:
		if os.path.exists(r"cache\\progress\\No internet. Retrying..."):
			open(r"cache\\progress\\No internet. Retrying...", "x")
		print('Error has occur during web request')
		print('Please check internet connection.')
		print('Retrying...')

#   wait for partionly load
open(r"cache\\progress\\Loading webpage...", "x")
print("Loading webpage...")
while True:
	timesError = 0
	try:
		WebDriverWait(driver, int(ConfigParserGet(Config, 'Setting', 'BrowserTimeout'))).until(EC.presence_of_element_located((By.XPATH, '/html[1]/body[1]/div[1]/div/div[3]/div/main/section[2]/ul[1]')))
	except:
		timesError += 1
		while True:
			timesError1 = 0
			try:
				driver.get("https://shopee.com/shopee-coins/")
			except:
				timesError1 += 1
			if not timesError1:
				break
	if not timesError:
		break
print("Webpage loaded!")

#	login stuff
if "login" in driver.page_source:
	open(r"cache\\progress\\Processing login", "x")
	#	Select language
	while True:
		EngLang = False
		FinishLoad = False
		try:
			EngLang = driver.find_element_by_xpath("/html[1]/body[1]/div[2]/div[1]/div[1]/div/div[3]/div[1]/button")
		except:
			print("searching: English language...")
			try:
				FinishLoad = driver.find_element_by_xpath("/html/body/div[1]/div/div[3]/div/main/section[2]/ul[2]")
			except:
				pass
			time.sleep(1)
		if EngLang:
			time.sleep(1)
			EngLang.click()
			print("English language selected!")
			break
		if FinishLoad:
			print("English language already selected")
			break
	#	Get QR
	time.sleep(1)
	open(r"cache\\progress\\Loading QRCode...", "x")
	driver.get('https://shopee.com/buyer/login/qr')
	# wait for QR to be display
	while True:
		print("Waiting for QR...")
		while True:
			timesError = 0
			try:
				WebDriverWait(driver, int(ConfigParserGet(Config, 'Setting', 'BrowserTimeout'))).until(EC.presence_of_element_located((By.XPATH, '/html[1]/body[1]/div[1]/div/div[2]/div/div/div/div/div[2]/div/div[1]/div/div')))
			except:
				timesError += 1
				driver.get('https://shopee.com/buyer/login/qr')
			if not timesError:
				break
		print("Fetching QR...")
		# Get QR
		while True:
			time.sleep(1)
			with open(r'cache\\QRCode.png', 'wb') as file:
				file.write(driver.find_element_by_xpath('/html[1]/body[1]/div[1]/div/div[2]/div/div/div/div/div[2]/div/div[1]/div/div').screenshot_as_png)
			QRImgRGB = PIL.Image.open(r'cache\\QRCode.png').convert("RGB")
			coor = x,y = 30,30
			if QRImgRGB.getpixel(coor)[0] < 10:
				break
			while True:
				timesError = 0
				try:
					if os.path.exists(r'cache\\QRCode.png'):
						os.remove(r'cache\\QRCode.png')
				except:
					timesError += 1
				if timesError == 0:
					break
		open(r"cache\\progress\\QRCode Loaded", "x")
		print("QR downloaded!")
		while True:
			QRRefresh = False
			try:
				QRRefresh = driver.find_element_by_xpath('/html[1]/body[1]/div[1]/div/div[2]/div/div/div/div/div[2]/div/div[1]/button')
			except:
				time.sleep(1)
			if QRRefresh:
				time.sleep(1)
				open(r"cache\\progress\\Reloading QRCode...", "x")
				print("Refreshing QR...")
				if os.path.exists(r'cache\\QRCode.png'):
					os.remove(r'cache\\QRCode.png')
				break
			if 'login' not in driver.current_url:
				QRRefresh = False
				break
		if QRRefresh:
			QRRefresh.click()
		else:
			driver.get('https://shopee.com/shopee-coins/')
			if os.path.exists(r'cache\\QRCode.png'):
				os.remove(r'cache\\QRCode.png')
			break

open(r"cache\\progress\\Login Complete", "x")
def WriteToday():
	yyyy = str(datetime.date.today().year)
	mm = str(datetime.date.today().month)
	if mm.__len__() == 1:
		mm = '0' + mm
	dd = str(datetime.date.today().day)
	if dd.__len__() == 1:
		dd = '0' + dd
	Config['UserData'] = {}
	Config['UserData']['LastCheck'] = yyyy + mm + dd
	while True:
		if(driver.find_element_by_xpath('/html[1]/body[1]/div[1]/div/div[3]/div/main/section[1]/div[1]/a/p').text != "0"):
			break
		time.sleep(0.5)
	Config['UserData']['CoinEarned'] = driver.find_element_by_xpath('/html[1]/body[1]/div[1]/div/div[3]/div/main/section[1]/div[1]/a/p').text
	with open(r"Data\\User\\config.ini", 'w') as configFile:
		Config.write(configFile)

# claim shopee coin ^_^
open(r"cache\\progress\\Collecting coin...", "x")
print("searching: collect coin button...")
while True:
	CollectButton = False
	try:
		CollectButton = driver.find_element_by_xpath("/html[1]/body[1]/div[1]/div/div[3]/div/main/section[1]/div[1]/button")
	except:
		time.sleep(1)
	if CollectButton:
		time.sleep(1.5)
		CollectButton.click()
		open(r"cache\\progress\\Coin collected", "x")
		print("Coin Collected!")
		WriteToday()
		break

# save cookie
open(r"cache\\progress\\Saving cookies...", "x")
pickle.dump(driver.get_cookies(), open(Config['Setting']['CookiesPath'], "wb"))
print("Cookie saved!!")

StopCheckForForceExit = True
time.sleep(0.5)
print('Exiting firefox...')
driver.close()
open(r"cache\\progress\\Settled", "x")
