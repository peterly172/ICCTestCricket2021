 CREATE TRIGGER TR_players_forinsert
 ON players
 FOR INSERT
 AS
 BEGIN
 DECLARE @id INT;
 DECLARE @name VARCHAR(100);
 DECLARE @role_id INT;
 DECLARE @team_id INT;
 SELECT @id = id, @name = name, @role_id = role_id, @team_id = team_id FROM INSERTED

 INSERT INTO playersAudit (id, audit_data) VALUES (@id, 'New player added with id = ' + Cast(@id AS NVARCHAR(5)) + ' is added at ' + Cast (GETDATE() AS NVARCHAR(20))
 )
 END

 INSERT INTO players (id, name, role_id, team_id) VALUES (8322, 'Ben Foakes', 3, 5003);

CREATE TRIGGER TR_players_fordelete
ON players
FOR DELETE
AS
BEGIN
DECLARE @id INT
SELECT @id = id FROM DELETED

INSERT INTO playersAudit (id, audit_data) VALUES (@id, 'An existing employee with ID = ' + Cast(@id AS NVARCHAR(5)) + ' is deleted at ' + Cast (GETDATE() AS NVARCHAR(20))
)
END


SELECT * FROM playersAudit

CREATE TRIGGER TR_players_forupdate
ON players
FOR UPDATE
AS 
BEGIN
DECLARE @id INT
DECLARE @OldName NVARCHAR(50), @NewName NVARCHAR(50)
DECLARE @OldRole_id INT, @NewRole_id INT
DECLARE @OldTeam_id INT, @NewTeam_id INT

DECLARE @AuditString NVARCHAR(100) 

SELECT * INTO #temptable FROM INSERTED

WHILE(EXISTS(SELECT id FROM #temptable))
BEGIN
SET @AuditString = ''

SELECT TOP 1 @id = id, @NewName = name, @NewRole_id = role_id, @NewTeam_id = team_id FROM #temptable

SELECT @OldName = name, @OldRole_id = role_id, @OldTeam_id = team_id FROM DELETED WHERE ID = @id


SET @AuditString = 'Player with id = ' + Cast(@id AS NVARCHAR(5)) + ' ' + 'changed'
IF (@OldName <> @NewName)
SET @AuditString = @AuditString + ' NAME from ' + @OldName + ' to ' + @NewName

IF (@OldRole_id <> @NewRole_id)
SET @AuditString = @AuditString + ' Role_ID from ' + Cast(@OldRole_id AS NVARCHAR(5)) + ' to ' + Cast(@NewRole_id AS NVARCHAR(5))

IF (@OldTeam_id <> @NewTeam_id)
SET @AuditString = @AuditString + ' Team_ID from ' + Cast(@OldTeam_id AS NVARCHAR(5)) + ' to ' + Cast (@NewTeam_id AS NVARCHAR(5)) 

INSERT INTO playersAudit (id, audit_data) VALUES(@id, @AuditString)
DELETE FROM #TempTable WHERE id = @id

END

END

SELECT * FROM playersAudit

UPDATE players SET name = 'Ben Foakes', role_id = 2 WHERE id = 8322;

CREATE VIEW vPlayersDetails
AS
SELECT p.id, p.name, r.role AS role, t.name AS team
FROM players p
JOIN roles r ON p.role_id = r.id
JOIN teams t ON p.team_id = t.id



CREATE TRIGGER tr_vPlayersDetails_InsteadOfInsert
ON vPlayersDetails INSTEAD OF INSERT
AS
BEGIN
BEGIN
DECLARE @role_id INT
DECLARE @team_id INT
SELECT @role_id = r.id FROM roles r
JOIN INSERTED ON INSERTED.role = r.role
SELECT @team_id = t.id FROM teams t
JOIN INSERTED ON INSERTED.team = t.name

IF(@role_id IS NULL)
BEGIN
	RAISERROR('Invalid Role Name. Please enter role', 16, 1)
	RETURN
END

IF(@team_id IS NULL)
BEGIN
	RAISERROR('Invalid Team Name. Please enter team name', 16, 1)
	RETURN
END

INSERT INTO players (id, name, role_id, team_id)
SELECT id, name, @role_id, @team_id
FROM INSERTED
END
END



CREATE TRIGGER TR_vPlayersDetails_InsteadOfUpdate
ON vPlayersDetails INSTEAD OF UPDATE
AS
BEGIN
	IF(UPDATE(id))
	BEGIN
		RAISERROR('ID cannot be changed', 16, 1)
		RETURN
	END

		IF(UPDATE(role))
	BEGIN
		DECLARE @role_id INT

		SELECT @role_id = r.id
		FROM roles r
		JOIN INSERTED
		ON INSERTED.role = r.role

		IF(@role_id IS NULL)
		BEGIN
			RAISERROR('Invalid Role', 16, 1)
			RETURN
		END

		UPDATE players SET role_id = @role_id
		FROM INSERTED
		JOIN players p
		ON p.id = INSERTED.id
		END

		IF(UPDATE(team))
	BEGIN
		DECLARE @team_id INT

		SELECT @team_id = t.id
		FROM teams t
		JOIN INSERTED
		ON INSERTED.team = t.name

		IF(@team_id IS NULL)
		BEGIN
			RAISERROR('Invalid Team Name', 16, 1)
			RETURN
		END

		UPDATE players SET team_id = @team_id
		FROM INSERTED
		JOIN players p
		ON p.id = INSERTED.id
		END

		IF(UPDATE(name))
		BEGIN
			UPDATE players SET name = INSERTED.name
			FROM INSERTED
			JOIN players p
			ON p.id = INSERTED.id
			END
	END

	SELECT * FROM vPlayersDetails
	UPDATE vPlayersDetails SET role = 'All-rounder' WHERE id = 8919
	DELETE FROM players WHERE id = 8919

	SELECT * FROM players