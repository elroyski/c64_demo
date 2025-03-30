# Instrukcje Git

Aby opublikować to repozytorium na przykład na GitHub, wykonaj następujące kroki:

1. Utwórz nowe repozytorium na GitHub

2. Dodaj zdalne repozytorium:
```
git remote add origin https://github.com/TWOJA_NAZWA_UZYTKOWNIKA/C64.git
```

3. Wypchnij kod do zdalnego repozytorium:
```
git push -u origin main
```

## Aktualizacja repozytorium

Po wprowadzeniu zmian, aby zaktualizować repozytorium, wykonaj:

```
git add .
git commit -m "Opis wprowadzonych zmian"
git push
```

## Wskazówki

1. Upewnij się, że pliki muzyczne (SID) są zignorowane przez .gitignore, aby nie przesyłać ich do repozytorium, jeśli są one objęte prawami autorskimi.

2. Pamiętaj o aktualizacji README.md, gdy wprowadzisz istotne zmiany w funkcjonalności.

3. Jeśli pracujesz z innymi osobami, korzystaj z gałęzi (branches):
```
git checkout -b nowa-funkcja
# ... wprowadź zmiany
git add .
git commit -m "Dodanie nowej funkcji"
git push -u origin nowa-funkcja
```

Następnie utwórz Pull Request na GitHubie, aby połączyć zmiany z główną gałęzią (main). 