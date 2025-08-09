import requests
from bs4 import BeautifulSoup
import sys
import os

def buscar_manga(manga):
    url = f"https://www.animeallstar30.com/search?q={manga}"
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
    }
    try:
        resp = requests.get(url, headers=headers)
        resp.raise_for_status()
    except requests.RequestException as e:
        print(f"Error al conectar: {e}")
        return

    soup = BeautifulSoup(resp.text, 'html.parser')
    urls_encontradas = []
    for h3 in soup.find_all('h3', class_='titulo'):
        a = h3.find('a', href=True)
        if a and manga.lower() in a.text.lower():
            nombre = a.text.strip()
            url = a['href']
            # Solo guardar si el nombre no es una URL
            if not nombre.startswith("http"):
                urls_encontradas.append((nombre, url))
    if urls_encontradas:
        ruta_base = os.path.join(os.path.expanduser("~"), "apk/manga-cli-dl/src/results")
        with open(os.path.join(ruta_base, "nombres.txt"), "w") as nombres_file:
            for nombre, url in urls_encontradas:
                nombres_file.write(f"{nombre}\n")
        with open(os.path.join(ruta_base, "urls.txt"), "w") as urls_file:
            for nombre, url in urls_encontradas:
                urls_file.write(f"{url}\n")
        print(f"Se guardaron {len(urls_encontradas)} nombres en nombres.txt y URLs en urls.txt")
    else:
        print("No se encontraron resultados.")
    

if len(sys.argv) < 2:
    print("Por favor, proporciona el nombre del manga a buscar.")
    sys.exit(1)

manga = sys.argv[1]
buscar_manga(manga)