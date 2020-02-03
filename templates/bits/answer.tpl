{* mandatory argument: $answer *}
{$highlighted=$highlighted|default:false}
{$flagBox=$flagBox|default:true}
{$voteBox=$voteBox|default:true}
{$addComment=$addComment|default:false}

<div class="voteContainer answer {if $highlighted}highlighted{/if}">
  {if $voteBox}
    {include "bits/scoreAndVote.tpl"
      type=Vote::TYPE_ANSWER
      object=$answer
      upvotePriv=User::PRIV_UPVOTE_ANSWER
      downvotePriv=User::PRIV_DOWNVOTE_ANSWER}
  {/if}

  <div class="voteMain">
    {include "bits/answerMain.tpl"}
  </div>
</div>
