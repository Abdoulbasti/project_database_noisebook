drop table if exists utilisateurs cascade;
drop table if exists concerts cascade;
drop table if exists personnes cascade;
drop table if exists groupes cascade;
drop table if exists associations_concerts cascade;
drop table if exists lieux_concerts cascade;
drop table if exists concerts_passes cascade;
drop table if exists concerts_futures cascade;
drop table if exists avis_utilisateurs cascade;
drop table if exists mots_cles cascade;
drop table if exists playlists cascade;
drop table if exists genres cascade;
drop table if exists musiques cascade;
drop table if exists participations cascade;
drop table if exists organisations_concerts cascade;
drop table if exists avis_tagues cascade;
drop table if exists annonces_concerts cascade;
drop table if exists tetes_affiches cascade;
drop table if exists sous_genres cascade;
drop table if exists reactions_musiques cascade;
drop table if exists styles cascade;
drop table if exists affichages_playlists cascade;
drop table if exists suivis cascade;
drop table if exists musiques_dans_playlists cascade;

/*
les tables : 
    concerts(id_concert[PK])

    utilisateurs(pseudo[PK])

    personnes(pseudo[PK], nom_personne, ville_personne, pseudo_suivi*, playlist_affichee*);

    groupes(pseudo[PK], nom_groupe, pseudo_suivi*, playlist_affichee*)

    associations_concerts(pseudo[PK], nom_association, pseudo_suivi*, playlist_affichee*)

    lieux_concerts(pseudo[PK], nom_lieu, enfant, ville, capacité,  pseudo_suivi*, playlist_affichee*)

    concerts_passes(id_concert, titre_concert, date_concer, prix, nombre_participant, avis_participant*)

    concerts_futures(id_concert, titre_concert, date_concert, prix)

    avis_utilisateurs(id_avis, pseudo*, note, commentaire)

    mots_cles(mot_cle)

    musiques(id_musique, titre, duree, date_publication,  auteur*)

    genres(nom_genre)

    playlists(nom_playlist)

Les relations : 
    affichages_playlists(pseudo*[PK], playlist_affichee*[PK])

    participations(pseudo*, id_concert*, participe)

    organisations_concerts(pseudo_assoc*, pseudo_lieu*, id_concert*)

    avis_tagues(id_avis*, mot_cle*)

    annonces_concerts(pseudo*, id_concert_futur*)

    tetes_affiches(pseudo_groupe*, concert*)

    sous_genres(genre*, sous_genre*) : genre est sous genre sous_genre

    reactions_musiques(pseudo*, id_musique*, note)

    styles(id_musique*, genre*)*/





--Creation du tregger pour le nombre max de playliste affichable(10)
CREATE OR REPLACE FUNCTION check_max_playlists() RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT COUNT(*) FROM affichages_playlists WHERE pseudo = NEW.pseudo) >= 10 THEN
    RAISE EXCEPTION 'Un utilisateur ne peut pas afficher plus de 10 playlists';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;



create table utilisateurs(
    pseudo varchar(30) primary key
);

create table concerts( 
    id_concert integer primary key
);

create table personnes (
    pseudo varchar(30) primary key,
    nom_personne text,
    ville_personne text,
    foreign key (pseudo) references utilisateurs(pseudo)
);

create table groupes(
    pseudo varchar(30) primary key,
    nom_groupe text,
    foreign key (pseudo) references utilisateurs(pseudo)
);

create table associations_concerts (
    pseudo varchar(30) primary key,
    nom_association text,
    foreign key (pseudo) references utilisateurs(pseudo)
);

create table lieux_concerts (
    pseudo varchar(30) primary key,
    nom_lieu text,
    adapte_aux_enfants boolean,
    ville text,
    capacité integer,
    foreign key (pseudo) references utilisateurs(pseudo)
);

create table genres (
    nom_genre varchar(30) primary key
);

create table mots_cles (
    mot_cle varchar(30) primary key
);

/*create table musiques (
    id_musique integer primary key,
    titre text, 
    duree integer, 
    date_publication date,
    auteur_groupe varchar(30),
    auteur_personne varchar(30),
    foreign key (auteur_groupe) references groupes(pseudo),
    foreign key (auteur_personne) references personnes(pseudo)
);*/

create table musiques (
    id_musique integer primary key,
    titre text, 
    duree integer, 
    date_publication date,
    auteur_groupe varchar(30),
    foreign key (auteur_groupe) references groupes(pseudo)
);


/*create table playlists (
    nom_playlist varchar(30) primary key
);*/
--appel tregger affichage de 10 playlist au max
create table playlists (
    nom_playlist varchar(30) primary key,
    id_musique integer,
    foreign key (id_musique) references musiques(id_musique)
);

create table affichages_playlists (
    pseudo varchar(30),
    playlist_affichee varchar(30),
    primary key (pseudo, playlist_affichee),
    foreign key (pseudo) references utilisateurs(pseudo),
    foreign key (playlist_affichee) references playlists(nom_playlist)
);

CREATE TRIGGER check_max_playlists_trigger
BEFORE INSERT ON affichages_playlists
FOR EACH ROW EXECUTE PROCEDURE check_max_playlists();



--tregger nombre de musique dans playlist
create table musiques_dans_playlists (
    nom_playlist varchar(30),
    id_musique integer,
    primary key (nom_playlist, id_musique),
    foreign key (nom_playlist) references playlists(nom_playlist),
    foreign key (id_musique) references musiques(id_musique)
);


create or replace function max_20_musiques() returns trigger as $$
begin
   if (select count(*) from musiques_dans_playlists where nom_playlist = new.nom_playlist) > 20 then
      raise exception 'Une playlist ne peut contenir que 20 musiques au maximum';
   end if;
   return new;
end;
$$ language plpgsql;
create trigger check_max_musiques
before insert on musiques_dans_playlists
for each row execute procedure max_20_musiques();


/*create table playlists (
    nom_playlist varchar(30) primary key,
    id_musique integer,
    foreign key (id_musique) references musiques(id_musique)
);*/

create table concerts_passes (
    id_concert integer primary key,
    titre_concert text,
    date_concert date,
    prix integer,
    nombre_participant integer,
    avis_participant integer,
    foreign key (id_concert) references concerts(id_concert)
);

create table concerts_futures (
    id_concert integer primary key,
    titre_concert text,
    date_concert date,
    prix integer,
    foreign key (id_concert) references concerts(id_concert)
);

create table avis_utilisateurs (
    id_avis integer primary key,
    pseudo varchar(30), 
    note integer,
    commentaire text,
    foreign key (pseudo) references utilisateurs(pseudo) 
);

--Si NULL one participe si
create table participations (
    pseudo varchar(30),
    id_concert integer,     
    participe boolean default false,      
    primary key (pseudo, id_concert),
    foreign key (pseudo) references personnes(pseudo), 
    foreign key (id_concert) references concerts(id_concert)
);


create table organisations_concerts (
    pseudo_assoc varchar(30),
    pseudo_lieu varchar(30),
    id_concert integer,
    primary key (pseudo_assoc, pseudo_lieu, id_concert),
    foreign key (pseudo_assoc) references associations_concerts(pseudo), 
    foreign key (pseudo_lieu) references lieux_concerts(pseudo),
    foreign key (id_concert) references concerts(id_concert)
);

create table avis_tagues (
    id_avis integer,
    mot_cle varchar(30),
    primary key (id_avis, mot_cle),
    foreign key (id_avis) references avis_utilisateurs(id_avis),
    foreign key (mot_cle) references mots_cles(mot_cle)
);

create table annonces_concerts (
    pseudo varchar(30),
    id_concert_futur integer,
    primary key (pseudo, id_concert_futur),
    foreign key (pseudo) references utilisateurs,
    foreign key (id_concert_futur) references concerts_futures(id_concert)
);

create table tetes_affiches (
    pseudo_groupe varchar(30),
    concert integer,
    primary key (pseudo_groupe, concert),
    foreign key (pseudo_groupe) references groupes(pseudo),
    foreign key (concert) references concerts(id_concert)
);

create table sous_genres (
    genre varchar(30),
    sous_genre varchar(30),
    primary key (genre, sous_genre),
    foreign key (genre) references genres(nom_genre),
    foreign key (sous_genre) references genres(nom_genre)
);

create table reactions_musiques (
    pseudo varchar(30),
    id_musique integer,
    note integer,
    primary key (pseudo, id_musique),
    foreign key (pseudo) references utilisateurs(pseudo),
    foreign key (id_musique) references musiques(id_musique)
);

create table styles (
    id_musique integer,
    genre varchar(30),
    primary key (id_musique, genre),
    foreign key (id_musique) references musiques(id_musique),
    foreign key (genre) references genres(nom_genre)
);

create table suivis (
    pseudo varchar(30),
    pseudo_suivi varchar(30),
    primary key (pseudo, pseudo_suivi),
    foreign key (pseudo) references utilisateurs(pseudo),
    foreign key (pseudo_suivi) references utilisateurs(pseudo)
);


\COPY utilisateurs FROM '../csv/utilisateurs.dat' WITH csv;
\COPY concerts FROM '../csv/concerts.dat'  WITH csv;
\COPY personnes FROM '../csv/personnes.dat' WITH csv;
\COPY groupes FROM '../csv/groupes.dat' WITH csv;
\COPY associations_concerts FROM '../csv/associations_concerts.dat'  WITH csv;
\COPY lieux_concerts FROM '../csv/lieux_concerts.dat' WITH csv;
\COPY concerts_passes FROM '../csv/concerts_passes.dat' WITH csv;
\COPY concerts_futures FROM '../csv/concerts_futures.dat'  WITH csv;
\COPY avis_utilisateurs FROM '../csv/avis_utilisateurs.dat' WITH csv;
\COPY mots_cles FROM '../csv/mots_cles.dat' WITH csv;
\COPY musiques FROM '../csv/musiques.dat'  WITH csv;
\COPY genres FROM '../csv/genres.dat' WITH csv;
\COPY playlists FROM '../csv/playlists.dat' WITH csv;
\COPY participations FROM '../csv/participations.dat'  WITH csv;
\COPY organisations_concerts FROM '../csv/organisations_concerts.dat' WITH csv;
\COPY avis_tagues FROM '../csv/avis_tagues.dat' WITH csv;
\COPY annonces_concerts FROM '../csv/annonces_concerts.dat'  WITH csv;
\COPY tetes_affiches FROM '../csv/tetes_affiches.dat' WITH csv;
\COPY sous_genres FROM '../csv/sous_genres.dat' WITH csv;
\COPY reactions_musiques FROM '../csv/reactions_musiques.dat'  WITH csv;
\COPY styles FROM '../csv/styles.dat' WITH csv;
\COPY suivis FROM '../csv/suivis.dat'  WITH csv;
\COPY affichages_playlists FROM '../csv/affichages_playlists.dat' WITH csv;
\COPY musiques_dans_playlists FROM '../csv/musiques_dans_playlists.dat' WITH csv;