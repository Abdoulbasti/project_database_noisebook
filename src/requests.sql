/*****************************************une requête qui porte sur au moins trois tables **************************************/
/*retourne les pseudos des utilisateurs, les titres des musiques et 
les genres de musiques pour les musiques qui ont une note égale ou supérieure à 4*/
SELECT U.pseudo, M.titre, G.nom_genre
FROM utilisateurs U, reactions_musiques RM, musiques M, styles S, genres G 
WHERE U.pseudo = RM.pseudo AND RM.id_musique = M.id_musique AND 
M.id_musique = S.id_musique AND S.genre = G.nom_genre AND RM.note >= 4;


-- Le tire des musiques et leur playliste de style jazz écouté parr John
SELECT musiques.titre, playlists.nom_playlist
FROM musiques, styles, playlists 
WHERE musiques.id_musique = styles.id_musique 
AND musiques.id_musique = playlists.id_musique
AND styles.genre = 'Jazz' AND playlists.pseudo = 'John';


/***************************une ’auto jointure’ ou ’jointure réflexive’ (jointure de deux copies d’une même table) ******************/
/*Les utilisateurs qui se suivent mutuelemnt*/
SELECT s1.pseudo, s2.pseudo_suivi
FROM suivis AS s1
JOIN suivis AS s2 ON s1.pseudo_suivi = s2.pseudo
WHERE s1.pseudo != s2.pseudo_suivi;



/***********************************************une sous-requête corrélée****************************************************/
/*liste des pseudos des utilisateurs qui ont affiché moins de 3 playlists.*/
SELECT u.pseudo
FROM utilisateurs u
WHERE EXISTS (
    SELECT *
    FROM affichages_playlists ap
    WHERE ap.pseudo = u.pseudo AND (SELECT COUNT(*) FROM affichages_playlists WHERE pseudo = u.pseudo) <=3
);




/*************************************************une sous-requête dans le FROM***************************************************/
/*Cette requête renvoie la liste des genres de musique et le nombre de musiques de chaque genre*/
SELECT genre_musique.genre, COUNT(*) AS nombre_musiques
FROM (
    SELECT m.id_musique, g.nom_genre as genre
    FROM musiques m
    JOIN styles s ON m.id_musique = s.id_musique
    JOIN genres g ON s.genre = g.nom_genre
)AS genre_musique
GROUP BY genre_musique.genre;




/***********************************************une sous-requête dans le WHERE ************************************************/
/*Cette requête retourne le pseudo et le nom du groupe de tous les groupes que l'utilisateur 'George' suit*/
SELECT pseudo, nom_groupe
FROM groupes
WHERE pseudo IN (SELECT pseudo_suivi FROM suivis WHERE pseudo = 'George');



/****************************************deux agrégats nécessitant GROUP BY et HAVING******************************************/
/*Cette requête retourne chaque groupe qui a moins de 5 musiques et dont la moyenne des 
notes de ses musiques est inferieure à 4.*/
SELECT musiques.auteur_groupe, COUNT(musiques.id_musique), AVG(reactions_musiques.note)
FROM musiques 
JOIN reactions_musiques ON musiques.id_musique = reactions_musiques.id_musique
GROUP BY musiques.auteur_groupe
HAVING COUNT(musiques.id_musique) < 5 AND AVG(reactions_musiques.note) < 4;



/*************une requête impliquant le calcul de deux agrégats (par exemple, les moyennes d’un ensemble de maximums)**********/
/*moyenne des notes maximales données par chaque utilisateur et la moyenne des prix 
les plus élevés pour les concerts où ces musiques ont été jouées.*/
SELECT 
    AVG(max_note) as avg_max_note, 
    AVG(max_prix) as avg_max_prix
FROM 
    (
        SELECT 
            MAX(reactions_musiques.note) as max_note,
            MAX(concerts_passes.prix) as max_prix
        FROM reactions_musiques 
        JOIN musiques ON reactions_musiques.id_musique = musiques.id_musique
        JOIN concerts_passes ON musiques.id_musique = concerts_passes.id_concert
        GROUP BY reactions_musiques.pseudo
    ) as subquery;


/************************************une jointure externe (LEFT JOIN, RIGHT JOIN ou FULL JOIN)***********************/

SELECT utilisateurs.pseudo, COUNT(concerts_futures.id_concert) AS concerts_futurs
FROM utilisateurs
LEFT JOIN annonces_concerts ON utilisateurs.pseudo = annonces_concerts.pseudo
GROUP BY utilisateurs.pseudo
ORDER BY concerts_futurs DESC;


--requête utilisant une jointure externe gauche :
SELECT U.pseudo, M.titre
FROM utilisateurs U
LEFT JOIN reactions_musiques RM ON U.pseudo = RM.pseudo
LEFT JOIN musiques M ON RM.id_musique = M.id_musique
WHERE RM.note IS NULL;

/**************deux requêtes équivalentes exprimant une condition de totalité, l’une avec des sous 
requêtes corrélées et l’autre avec de l’agrégation*******************************************************************/

/*nom et pseudo des groupes ayant composé au moins une musique*/
SELECT g.pseudo, g.nom_groupe
FROM groupes g
WHERE EXISTS (
    SELECT *
    FROM musiques m
    WHERE m.auteur_groupe = g.pseudo
);

SELECT g.pseudo, g.nom_groupe
FROM groupes g
JOIN musiques m ON g.pseudo = m.auteur_groupe
GROUP BY g.pseudo, g.nom_groupe
HAVING COUNT(m.id_musique) > 0;





/*deux requêtes qui renverraient le même résultat si vos tables ne contenaient pas de nulls, mais
qui renvoient des résultats différents ici (vos données devront donc contenir quelques nulls), vous
proposerez également de petites modifications de vos requêtes (dans l’esprit de ce qui sera présenté
dans le cours sur l’information incomplète) afin qu’elles retournent le même résultat*/



/*une requête récursive (par exemple, une requête permettant de calculer quel est le prochain jour
off d’un groupe actuellement en tournée) ;
Exemple : Napalm Death est actuellement en tournée (Campagne for Musical Destruction 2023),
ils jouent sans interruption du 28/02 au 05/03, mais ils ont un jour off le 06/03 entre Utrecht
(05/03) et Bristol (07/03). En supposant qu’on est aujourd’hui le 28/02, je souhaite connaître leur
prochain jour off, qui est donc le 06/03.*/




/*une requête utilisant du fenêtrage (par exemple, pour chaque mois de 2022, les dix groupes dont
les concerts ont eu le plus de succès ce mois-ci, en termes de nombre d’utilisateurs ayant indiqué
souhaiter y participer)*/