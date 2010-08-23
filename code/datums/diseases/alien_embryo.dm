//affected_mob.contract_disease(new /datum/disease/alien_embryo)







/datum/disease/alien_embryo
	name = "Unidentified Foreign Body"
	max_stages = 5
	spread = "None"
	cure = "Unknown"
	affected_species = list("Human", "Monkey")

/datum/disease/alien_embryo/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "\red Your throat feels sore."
			if(prob(1))
				affected_mob << "\red Mucous runs down the back of your throat."
		if(3)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "\red Your throat feels sore."
			if(prob(1))
				affected_mob << "\red Mucous runs down the back of your throat."
		if(4)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(2))
				affected_mob << "\red Your muscles ache."
				if(prob(20))
					affected_mob.bruteloss += 1
					affected_mob.updatehealth()
			if(prob(2))
				affected_mob << "\red Your stomach hurts."
				if(prob(20))
					affected_mob.toxloss += 1
					affected_mob.updatehealth()
		if(5)
			affected_mob << "\red You feel something tearing its way out of your stomach..."
			affected_mob.toxloss += 10
			affected_mob.updatehealth()
			if(prob(40))
				var/list/candidates = list() // Picks a random ghost in the world to shove in the larva -- TLE
				for(var/mob/dead/observer/G in world)
					if(G.client)
						if(!G.client.holder && ((G.client.inactivity/10)/60) <= 5)
							candidates.Add(G)
				if(candidates.len)
					var/mob/dead/observer/G = pick(candidates)
					G.client.mob = new/mob/living/carbon/alien/larva(affected_mob.loc)
				else
					if(affected_mob.client)
						affected_mob.client.mob = new/mob/living/carbon/alien/larva(affected_mob.loc)
				affected_mob.gib()

			/*
				if(affected_mob.client)
					affected_mob.client.mob = new/mob/living/carbon/alien/larva(affected_mob.loc)
				else
					new/mob/living/carbon/alien/larva(affected_mob.loc)
				affected_mob:gib()
			*/
				return

