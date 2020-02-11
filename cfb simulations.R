
library(tidyverse)
library(cfbscrapR)

#GET DATA 

pbp_2019 <- data.frame()
for(i in 1:15){
  data <- cfb_pbp_data(year = 2019, season_type = "regular", week = i, epa_wpa = TRUE) %>% mutate(week = i)
  df <- data.frame(data)
  pbp_2019 <- bind_rows(pbp_2019, df)
} 


pbp_2018 <- data.frame()
for(i in 1:15){
  data <- cfb_pbp_data(year = 2018, season_type = "regular", week = i, epa_wpa = TRUE) %>% mutate(week = i)
  df <- data.frame(data)
  pbp_2018 <- bind_rows(pbp_2018, df)
} 


pbp_2017 <- data.frame()
for(i in 1:15){
  data <- cfb_pbp_data(year = 2017, season_type = "regular", week = i, epa_wpa = TRUE) %>% mutate(week = i)
  df <- data.frame(data)
  pbp_2017 <- bind_rows(pbp_2017, df)
} 

pbp_2016 <- data.frame()
for(i in 1:15){
  data <- cfb_pbp_data(year = 2016, season_type = "regular", week = i, epa_wpa = TRUE) %>% mutate(week = i)
  df <- data.frame(data)
  pbp_2016 <- bind_rows(pbp_2016, df)
} 


pbp_2015 <- data.frame()
for(i in 1:15){
  data <- cfb_pbp_data(year = 2015, season_type = "regular", week = i, epa_wpa = TRUE) %>% mutate(week = i)
  df <- data.frame(data)
  pbp_2015 <- bind_rows(pbp_2015, df)
} 

pbp_2014 <- data.frame()
for(i in 1:15){
  data <- cfb_pbp_data(year = 2014, season_type = "regular", week = i, epa_wpa = TRUE) %>% mutate(week = i)
  df <- data.frame(data)
  pbp_2014 <- bind_rows(pbp_2014, df)
} 

tmp <- rbind(pbp_2019, pbp_2018) 
tmp1 <- rbind(tmp, pbp_2017)
tmp2 <- rbind(tmp1, pbp_2016)
tmp3 <- rbind(tmp2, pbp_2015)
plays <- rbind(tmp3, pbp_2014) 

# PUNT SIMULATOR
punt19 <- pbp_2019 %>% filter(play_type == "Punt" & yards_gained >0) %>% select(play_text, adj_yd_line, yards_gained, pnet = yards_gained)
punt18 <- pbp_2018 %>% filter(play_type == "Punt" & yards_gained >0) %>% select(play_text, adj_yd_line, yards_gained, pnet = yards_gained)
punt17 <- pbp_2017 %>% filter(play_type == "Punt" & yards_gained >0) %>% select(play_text, adj_yd_line, yards_gained, pnet = yards_gained)
punt16 <- pbp_2016 %>% filter(play_type == "Punt" & yards_gained >0) %>% select(play_text, adj_yd_line, yards_gained, pnet = yards_gained)
punt15 <- pbp_2015 %>% filter(play_type == "Punt" & yards_gained >0) %>% select(play_text, adj_yd_line, yards_gained, pnet = yards_gained)
punt14 <- pbp_2014 %>% filter(play_type == "Punt" & yards_gained >0) %>% select(play_text, adj_yd_line, yards_gained, pnet = yards_gained)

tmp <- rbind(punt19, punt18) 
tmp1 <- rbind(tmp, punt17)
tmp2 <- rbind(tmp1, punt16)
tmp3 <- rbind(tmp2, punt15)
punts <- rbind(tmp3, punt14)

punt <- punts %>% separate(play_text, c("punter", "junk"), sep = " punt for ")
punt2 <- punt %>% separate(junk, c("puntyards", "junk1"), sep = " yds ") %>% separate(puntyards, c("puntyards", "junk"), sep = "yds ,") %>% 
  separate(puntyards, c("puntyards", "junk6"), sep = "yds,") %>% mutate(puntyards = trimws(puntyards), puntyards = as.numeric(puntyards))

sample.punt <-function(yds){
data.punt <- punt2 %>% filter(adj_yd_line >= yds - 5 | adj_yd_line <= yds + 5)
sim.punt <- sample_n(data.punt,1)
print(paste("The net number of punting yards is ", sim.punt$puntyards,
            ". The ball is spotted ", sim.punt$adj_yd_line - sim.punt$puntyards, 
            " yards from the defense's end zone. The defensive team takes possession ", 
            100 - (sim.punt$adj_yd_line - sim.punt$puntyards), " yards from the offense's end zone", sep = ""))
}



# FG SIMULATOR
fg <- plays %>% filter(play_type %in% c("Field Goal Good", "Field Goal", "Field Goal Missed", "Blocked Field Goal", "Blocked Field Goal Touchdown")) %>%
  mutate(result = ifelse(play_type == "Field Goal Good", "Make",
                         ifelse(play_type %in% c("Blocked Field Goal", "Blocked Field Goal Touchdown"), "Blocked", "Missed"))) %>%
  separate(play_text, c("kickerfirst", "kickerlast", "yd", "junk"), sep = " ") %>% mutate(yd = as.numeric(yd)) %>% filter(!is.na(yd)) %>% 
  select(yd, result)

sample.fg <- function(ydline){
  data.FG <- fg %>% filter(yd >= ydline - 3, yd <= ydline + 3)
  sim.FG <- sample_n(data.FG, 1)
  if(sim.FG$result == "Make"){print(paste("The field goal attempt from ", ydline,
                              " yards is GOOD! (3 pts)", sep = ""))
  } else if(sim.FG$result == "Missed"){print(paste("The field goal attempt from ", ydline,
                                            " yards is NO GOOD! ", "The defense takes possession at its own ", sim.FG$yd, " yard line.", sep = ""))
 }  else {print(paste("The field goal is BLOCKED! The defense takes over at its own ", sim.FG$yd, " yard line.", sep = ""))}
}

# PLAY SIMULATOR

playsim <- plays %>% filter(rush ==1 | pass ==1) %>% select(down, distance, adj_yd_line, play_type, yards_gained)
sample.play <- function(ydline, dwn, dist){
  data.plays <- plays %>% filter(down == dwn, distance <= dist + 5, distance >= dist - 5 , adj_yd_line == ydline)
  sim.plays <- sample_n(data.plays, 1)
  if(sim.plays$play_type == "Rush" & sim.plays$yards_gained >= sim.plays$distance) { 
    paste("You called a rush which gained ", sim.plays$yards_gained, " yards and picked up a first down.", sep = "")
  }
  else if(sim.plays$play_type == "Rush" & sim.plays$yards_gained < sim.plays$distance){
    paste("You called a rush which gained ", sim.plays$yards_gained, "  yards and failed to pickup a first down.", sep = "")
  }
  else if(sim.plays$play_type == "Rushing Touchdown") {
    paste("You called a rush which scored a touchdown! (7pts)")
  }
  else if(sim.plays$play_type == "Pass Incompletion") {paste("You called a pass, which was incomplete.", sep = "")
  }
  else if(sim.plays$play_type == "Pass Reception" & sim.plays$yards_gained >= sim.plays$distance){
    paste("You called a pass, which gained ", sim.plays$yards_gained, " yards and picked up a first down.", sep = "")
  }
  else if(sim.plays$play_type == "Pass Reception" & sim.plays$yards_gained < sim.plays$distance){
    paste("You called a pass, which gained ", sim.plays$yards_gained, " yards and failed to pickup a first down.", sep = "")
  }
  else if(sim.plays$play_type == "Sack"){
    paste("You called a pass and were sacked for ", sim.plays$yards_gained, " yards and failed to pickup a first down.", sep = "")
  }
  else if(sim.plays$play_type == "Passing Touchdown"){
    paste("You called a pass which scored a touchdown! (7 points)")
  }
  else if(sim.plays$play_type %in% c("Fumble Recovery (Opponent)", "Fumble Recovery (Own)")){
    print("You fumbled the ball and the defense recovered! Defense takes over at the", 100 - adj_yd_line, ".", sep = "")
  }
  else if(sim.plays$play_type == "Pass Interception Return"){
    paste("You called a pass and threw an interception!. The defense takes over at their ", 100-adj_yd_line, ".", sep = "")
  }
  else{paste("Safety! (-2pts)")}
}
