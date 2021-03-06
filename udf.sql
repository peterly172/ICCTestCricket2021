CREATE FUNCTION [dbo].[fnGetTotalRunsByPlayer]
(
@player_id AS INT
)
RETURNS INT
AS
BEGIN
	DECLARE @runs AS INT
	SELECT
	@runs = SUM(runs)
	FROM testruns t
	WHERE t.player_id = @player_id
	GROUP BY t.player_id

	RETURN @runs
END

CREATE FUNCTION dbo. GetTotalWicketsByBowler
(
@player_id AS INT
)
RETURNS INT
AS
BEGIN
	DECLARE @wickets AS INT
	SELECT
	@wickets = COUNT(bowler_id)
	FROM testruns t
	WHERE t.bowler_id = @player_id
	GROUP BY t.bowler_id

	RETURN @wickets
END

CREATE FUNCTION dbo. GetTotalWicketsByBowler
Go

SELECT dbo.GetTotalWicketsByBowler(8810);