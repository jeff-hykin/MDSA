function [  apprentices_  ] = MDSA (  number_of_apprentices , role_model             = 1 , standard_dev           = 1 , characteristic_weights = ones ( size ( role_model ) ) , pythagorean_distance   = 1    ) 
warning ("off", "Octave:broadcast"); ;
%%% the bell curve (aka the normal distribution, the Gaussian), does not form a bell in hyperspace (>3 dimensions) 
%%% this is because there is a higher chance of getting a value further from the mean than close to it
%%% this function is a solution to this problem. I call it the multi-dimension similarity algorithm (MDSA) 
%%% with pythagorean_distance on (enabled byu default) it acts much in the same way as a Gaussian
%%% the only mathematically significant addition is that of a dimesnions_weights , which is optional (ones by default) 

%%% I use analogies to make the math and code more intuitive, so here is a translation beforehand. 
%%% the mean is represented as the role_model 
%%% the number of random points the function will generate is called the number_of_apprentices 
%%% the over all standard deviation is just the standard_dev 
%%% a sort of standard deviation for individual dimensions is represented by the characteristic_weights 


 
   %%% number_of_apprentices  needs to be a scalar 
   %%% role_model             needs to be a column vector (aka vector transpose) with each column being a feature ./ dimension
   %%% standard_dev  needs to be a scalar 
   %%% characteristic_weights needs to be a column vector with each column being the weight (a conversion constant) for that specific characteristic 
   
   %%% DEFAULT  role_model             = 1 
   %%% DEFAULT  standard_dev           = 1 
   %%% DEFAULT  characteristic_weights = ones ( size ( role_model ) ) 
   %%% DEFAULT  pythagorean_distance   = 1   
    

 

 %%%% there are two given ways to measure distance 
 %%%% this gives you a choice between them (read below for details)
     %%% the first type (and default) is pythagorean_distance 
     %%% its just drawing a line from one point to another and finding the hypotenuse
     %%% the second is actually more simple, it's just adds the dimensions, thats it 
     %%% Ex; the pythagorean_distance between point a (0,0) and point b (5,5) is 7.071 ( aka sqrt(50) ) 
     %%%     the other distance between a and b would be 10 
     %%% for some pratical applications the second method can be more useful (its also slightly faster)
     %%% but the pythagorean_distance is statistically correct 
        %%% this is implemented here as function handles so that 
        %%% the if statment is only evaluated once rather than every time a change is made  
         if    pythagorean_distance == 1 ;
               _distance    = @( point_ ) ( sum ( point_ .^ 2 ).^( 1 ./ 2 ) );
               _max_allowed = @( previous_others , allowed_ , previous_one ) ( allowed_ .^ 2 - sum ( previous_others .^ 2 ) ).^( 1 ./ 2 ) - previous_one ;
         else  ;
               _distance    = @( point_ ) sum ( point_ );
               _max_allowed = @( previous_others , allowed_ , previous_one ) allowed_ - ( sum ( previous_others ) + previous_one ) ;
         endif ;

 %%% lets define the number_of_characteristics   
      PLACEHOLDER_ = size ( role_model  ) ;
      number_of_characteristics  = PLACEHOLDER_ ( 2 ) ;


%        Setting The Caps         ;
%======================================================== ;

%%%% we've got to decide how much we're going to allow any one apprentice to deviate from the role_model 
     %%% so we're going to generate random values based on a normal distribution 
     %%% and use those values as the maximum_distance , one value for each apprentice
     %%% and we'll need to make it an absolute value because it's a distance
     %%% and because it's an absolute value (both sides now combined onto one side) we need to divide it by 2 
     local_mean          = 0 ;
     normal_distribution = normrnd ( local_mean , standard_dev , number_of_apprentices , 1 )       ;
     maximum_distance    = abs ( normal_distribution  ) ./ 2 ;


%        Core Loops         ;
%========================================================;

%%%% here is the OVERsimplified conceptual version of the program  
    %%% There are several very important details missing from this, it's meant to get a general idea only 
    %%% The program starts by taking the maximum_distance value and assigning it to an apprentice.
    %%% that value is how much the apprentice is allowed to deviate total from the role_model 
    
    %%% then the first apprentice is chosen ( loop_1 ) 
    %%% and a random characteristic is chosen ( loop_2 ) for that apprentice only
    %%% then proposal is made, 
    %%% in the form of a proposed_change to the_chosen_characteristic 
    %%% ( a random, normally distributed, positive-only change )  
    %%% in order to test this proposal, a proposed_apprentice is made 
    
    %%% if the distance_to_the_proposed_apprentice is < the maximum_distance 
    %%% then loop_2 repeats, picking another random characteristic and making another proposed_change 
    %%% ( if a characteristic is chosen twice, the new proposed_change is added to the existing change )

    %%% however if the distance_to_the_proposed_apprentice is >= the maximum_distance 
    %%% then we deny the proposed_change 
    %%% and instead the new_change is set to be;
    %%%     however much the_chosen_characteristic could change 
    %%%     while still keeping the proposed distance <= the maximum_distance 
        %%% ( with some algrbra proposed_change is actually directly calculated 
        %%%   making the proposed distance == the maximum_distance )
         
    %%% then (because no more change can be made) we move on to the next apprentice and repeat  

    %%% Once all the apprentices are done we have to do a few more things 
    %%% because all the changes are positive (and thats not what we want)
    %%% we decide randomly (50./50 chance) if the change to a characteristic will be negative or positive 
    
    %%% then because the apprentices are just copies of the role_model with some changes 
    %%% we make copies of the role_models and add the changes to them
    %%% then we output the apprentices and the program is done!
    %%% There are several details missing, but this is the general concept 



     %%% here's some things that need to be declared before the loop
     %%%        Pre-Loop Values 
     %%% ////////////////////////////
     %%% we're going to start with the first apprentice       
         for_this_apprentice = 1  ;
     %%% we're going to keep a record of the total change to all characteristics of all apprentice 
     %%% (and currently there are no changes)  
         approved_changes = zeros ( number_of_apprentices , number_of_characteristics )  ;
     %%% \\\\\\\\\\\\\\\\\\\\\\\\\\\\
     %%%        End Pre-Loop Values


     %%% we're going to keep making changes until we have enough apprentices 
     while  for_this_apprentice <= number_of_apprentices ;

     %%%% first we need to pick a random characteristic to change 
         for_current_characteristic = randi ( number_of_characteristics , 1 );
     
     %%%% and lets pick how much to change it by     
     %%%% we don't want all of the change for an apprentice to be consumed all at once on one characteristic 
     %%%% so we're going to divide the proposed_change by the number_of_characteristics so that we have a more
     %%%% changes that are less radical 
         %%% to understand this better think of maximum_distance as a cake and this step is deciding
         %%% how big the pieces of cake are. If you have 5 people ( 5 characteristics) but you don't split the 
         %%% cake up, that means one person is going to get the whole cake and everyone else is going to get 
         %%% none. However if you divide the cake evenly by the number of people (number_of_characteristics) then 
         %%% you'll have 5 pieces of cake, and you can (at least) give everyone 1 piece. 

         %%% Now because we're randomly choosing who gets cake (which characteristic), it will more likely end up being 
         %%% 1 person gets 3 pieces, 2 people get 1 piece, and 2 people get no cake (or some similar distribution)

         %%% we could cut the cake into 10,000 pieces, and then it would be likely that each person got a nearly even 
         %%% amount. However we don't want everyone to have an even amount. We want some groups to have an even amount
         %%% and we want other groups to have one person get the whole cake (because we're evil experimenters like that 
         %%% and want to see how people react in every possible scenario). However some would debate that cutting the 
         %%% cake into 10 pieces would be a compromise, and to that I say "...yeah it probably would work and I'm not 
         %%% 100% sure the metaphorical 5 is better than the metaphorical 10, I'll test this later and see how this 
         %%% effects output. maybe I'll make it a parameter that is part of the input" 

         %%% However aside from cake distribution, cutting a cake into 10,000 pieces is really hard, and giving out 
         %%% 10,000 pieces would take a long time. Similarly if we made this value really small it would require a lot 
         %%% more computation power and ./ or runtime.

         %%% also keep in mind the cakes are randomly different sizes, and we are only changing the average size of
         %%% the pieces, so it's actually kinda like real life where the pieces are not evenly cut, and sometimes the
         %%% you get an extra piece because you cut the first ones too small.
         local_mean          = 0 ;
         local_deviation     = maximum_distance ( for_this_apprentice ) ./ number_of_characteristics ;
         normal_distribution = normrnd ( local_mean , local_deviation , 1 );
         proposed_change     = abs ( normal_distribution  ) ;

 
         %%% and now we need to know how much the proposed change effects the distance 
         proposed_changes = approved_changes ( for_this_apprentice , : );
         proposed_changes ( for_current_characteristic )  =   proposed_changes ( for_current_characteristic )  + proposed_change ;
         proposed_distance = _distance ( proposed_changes );


                   %%%%  now we're going to check if the proposed_distance is less than the maximum_distance 
             if    proposed_distance  < maximum_distance ( for_this_apprentice );
             
                   %%%% if it is, then we're going to go ahead and add it to approved_changes  
                   approved_changes ( for_this_apprentice , for_current_characteristic )  =    approved_changes ( for_this_apprentice , for_current_characteristic )   + proposed_change  ;
         

                   %%%% if the proposed_distance is above the limit 
             else   ;
                   %%%% then we're going reject the proposed_change 
                   %%%% but we're going to make the new_change as large as possible (without going over the max)
                   other_characteristics  = approved_changes ( for_this_apprentice , : );
                   other_characteristics ( for_current_characteristic ) = 0 ;
                   current_characteristic = approved_changes ( for_this_apprentice , for_current_characteristic ) ;
                   new_change             = _max_allowed ( other_characteristics , maximum_distance ( for_this_apprentice ) , current_characteristic );

                   %%%% then we're going to add the new_change to the list (matrix) of approved_changes 
                   approved_changes ( for_this_apprentice , for_current_characteristic )  =   approved_changes ( for_this_apprentice , for_current_characteristic )  + new_change  ;
    
                   %%%% and then we're going to move onto the next apprentice            
                   for_this_apprentice  =   for_this_apprentice  .+ 1               ;
                   endif ;
 
 
     %%%% once we're done with all the apprentices 
     endwhile ;
     
     %%%% we've got to fix all of changes because currently they're all positive 
     %%%% andthey need to be (randomly) either positive or negative 
     matrix_of_random_ones_and_zeros      = randi ( 2 , size ( approved_changes ) ) - 1                          ;
     matrix_of_negitive_and_positive_ones = matrix_of_random_ones_and_zeros + ( matrix_of_random_ones_and_zeros .- 1 );
     negitive_and_positive_changes        = approved_changes .* matrix_of_negitive_and_positive_ones              ;

 
     %%%% lastly, not all characteristics are created equal
     %%%% so we must scale them accordingly 
     %%%% which basically just means multiplying each on by some constant
     %%% For example, a 1 foot change in fingernail length is not the same as
     %%% a 1 foot change in height. So to solve this problem the changes are scaled (up or down) depending 
     %%% on the characteristic being chosen ( the scale itself is set by the input variable characteristic_weights )
     %%% in theory there could also be an equation instead of just a constant 
     weights_ = repmat ( characteristic_weights , number_of_apprentices , 1 ) ;
     final_form_of_changes = negitive_and_positive_changes .* weights_ ;

     %%%% and then were going to add the final_form_of_changes to the role_model to produce apprentices_ 
     apprentices_ =  role_model .+ final_form_of_changes  ;
 

 endfunction 

