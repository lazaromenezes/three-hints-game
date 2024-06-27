extends VBoxContainer

func enter_data(rank: int, rank_summary):
	%Rank.text = "%s." % rank
	%Name.text = rank_summary.player
	%Points.text = str(rank_summary.points)
	%Time.text = rank_summary.formatted_time
