#1. Rank TOP 10 artists by the number of tracks in Spotify charts:
SELECT 
    ar.artist_id, 
    ar.artist_name, 
    COUNT(s.spotify_id) AS spotify_chart_entries, 
    RANK() OVER (ORDER BY COUNT(s.spotify_id) DESC) AS artist_rank
FROM 
    Artist ar
JOIN 
    `Release` `r` ON ar.artist_id = `r`.artist_id
JOIN 
    Track t ON `r`.track_id = t.track_id
JOIN 
    Spotify s ON t.track_id = s.track_id AND s.in_spotify_charts = 1
GROUP BY 
    ar.artist_id, ar.artist_name
ORDER BY 
    spotify_chart_entries DESC
LIMIT 10;

#2.Which artists demonstrate the most energetic and danceable tracks on average, and how prominently 
#do these attributes feature in their presence within Spotify playlists?
SELECT 
    ar.artist_name,
    AVG(t.`energy_%`) AS average_energy,
    AVG(t.`danceability_%`) AS average_danceability,
    COUNT(s.spotify_id) AS playlist_frequency
FROM 
    Artist ar
JOIN 
    `Release` r ON ar.artist_id = r.artist_id
JOIN 
    Track t ON r.track_id = t.track_id
JOIN 
    Spotify s ON t.track_id = s.track_id
WHERE 
    s.in_spotify_playlists > 0
GROUP BY 
    ar.artist_name
HAVING 
    AVG(t.`energy_%`) > 50 AND AVG(t.`danceability_%`) > 50
ORDER BY 
    playlist_frequency DESC
    limit 10;

#3. Artist with the greatest number of tracks across multiple platforms along with his most popular tracks
SELECT 
    ar.artist_id, 
    ar.artist_name,
    t.track_name,
    (IFNULL(s.spotify_count, 0) + IFNULL(a.apple_count, 0) + IFNULL(d.deezer_count, 0)) AS total_platform_count
FROM 
    (SELECT 
         `r`.artist_id, 
         COUNT(DISTINCT `r`.track_id) AS track_count
     FROM 
         `Release` `r`
     JOIN Spotify s ON `r`.track_id = s.track_id
     JOIN Apple a ON `r`.track_id = a.track_id
     JOIN Deezer d ON `r`.track_id = d.track_id
     GROUP BY 
         `r`.artist_id
     ORDER BY 
         track_count DESC
     LIMIT 1) AS top_artist
JOIN 
    Artist ar ON top_artist.artist_id = ar.artist_id
JOIN 
    `Release` `r` ON ar.artist_id = `r`.artist_id
JOIN 
    Track t ON `r`.track_id = t.track_id
LEFT JOIN 
    (SELECT track_id, COUNT(*) AS spotify_count FROM Spotify GROUP BY track_id) s ON t.track_id = s.track_id
LEFT JOIN 
    (SELECT track_id, COUNT(*) AS apple_count FROM Apple GROUP BY track_id) a ON t.track_id = a.track_id
LEFT JOIN 
    (SELECT track_id, COUNT(*) AS deezer_count FROM Deezer GROUP BY track_id) d ON t.track_id = d.track_id
ORDER BY 
    total_platform_count DESC
LIMIT 10;

#4. Which tracks are popular on all platforms- Spotify, Apple and Deezer (appear in playlists and charts)?
SELECT 
    ar.artist_id, 
    ar.artist_name,
    t.track_name,
    COUNT(DISTINCT s.spotify_id) AS spotify_count,
    COUNT(DISTINCT a.apple_id) AS apple_count,
    COUNT(DISTINCT d.deezer_id) AS deezer_count
FROM 
    Artist ar
JOIN 
    `Release` r ON ar.artist_id = r.artist_id
JOIN 
    Track t ON r.track_id = t.track_id
LEFT JOIN 
    Spotify s ON t.track_id = s.track_id AND s.in_spotify_playlists > 1 AND s.in_spotify_charts > 1
LEFT JOIN 
    Apple a ON t.track_id = a.track_id AND a.in_apple_playlists > 1 AND a.in_apple_charts > 1
LEFT JOIN 
    Deezer d ON t.track_id = d.track_id AND d.in_deezer_playlists > 1 AND d.in_deezer_charts > 1
GROUP BY 
    ar.artist_id, ar.artist_name, t.track_id, t.track_name
ORDER BY 
    (IFNULL(spotify_count, 0) + IFNULL(apple_count, 0) + IFNULL(deezer_count, 0)) DESC
LIMIT 10;

#5. What is the average number of streams per playlist inclusion for Spotify?

SELECT 
	ROUND(AVG(streams / in_spotify_playlists)) AS avg_streams_per_playlist 
    FROM Spotify WHERE in_spotify_playlists > 0;

#6. Top 10 tracks with the highest 'liveness' and their corresponding danceability and energy:  
SELECT 
    t.track_id, 
    t.track_name, 
    t.`liveness_%`,
	t.`danceability_%`,
    t.`energy_%`
FROM 
    Track t
ORDER BY 
    t.`liveness_%` desc
LIMIT 10;

#7. Most common key and mode combination among the top-streamed tracks on Spotify
SELECT 
    t.`key`, 
    t.mode, 
    ROUND(SUM(s.streams) / 1e9, 2) AS total_streams_in_billions
FROM 
    Track t
JOIN 
    Spotify s ON t.track_id = s.track_id
GROUP BY 
    t.`key`, t.mode
ORDER BY 
    total_streams_in_billions DESC
LIMIT 1;

#8. Which month of the year typically sees the most track releases?
SELECT 
    MONTHNAME(r.released_date) AS release_month_name, 
    COUNT(*) AS track_count
FROM 
    `Release` r
GROUP BY 
    release_month_name
ORDER BY 
    track_count DESC;

