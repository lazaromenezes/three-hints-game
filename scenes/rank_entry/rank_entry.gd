extends VBoxContainer

func enter_data(rank: int, session):
	%Rank.text = "%s." % rank
	%Name.text = session.player_name
	%Points.text = str(session.total_points)
	%Time.text = session.formatted_time
