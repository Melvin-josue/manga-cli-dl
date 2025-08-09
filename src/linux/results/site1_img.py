import requests
from bs4 import BeautifulSoup
import sys
import os

def buscar_src(url):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'}
    try:
        req = requests.get(url, headers=headers)
        req.raise_for_status()
    except requests.RequestException as e:
        print(f"Error al conectar: {e}")
        return

    soup = BeautifulSoup(req.text, 'html.parser')
    img = soup.find_all('img', src=True)

    ruta = os.path.join(os.path.expanduser("~"), "apk/manga-cli-dl/src/results/imagenes.txt")
    with open(ruta, "w") as f:
        for mg in img:
            webp = mg['src']
            f.write(f"{webp}\n")

if len(sys.argv) < 2:
    print("Por favor, proporciona la URL del manga a buscar.")
    sys.exit(1)
    
url = sys.argv[1]
buscar_src(url)

