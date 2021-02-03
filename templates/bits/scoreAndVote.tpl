{* $type: type of object being voted *}
{* $object: object being voted (should have id and score fields) *}

{* Tooltips are managed in wrapper divs. Bootstrap recommends this approach *}
{* when the underlying button may be disabled. *}

{$voteValue=$object->getVote()->value|default:0}
{$tooltipUpvote=$tooltipUpvote|default:''}
{$tooltipDownvote=$tooltipDownvote|default:''}

{* include the various confirmation messages just once *}
{if !isset($VOTE_REMINDER_MESSAGES_ONCE)}
  {$VOTE_REMINDER_MESSAGES_ONCE=1 scope="global"}
  <div id="vote-reminder-messages" style="display: none">
    {if User::needsVoteReminder()}
      {include "bits/toast.tpl"
        id="toast-upvote"
        msg="{t}info-confirm-upvote{/t}"}

      {include "bits/toast.tpl"
        id="toast-downvote"
        status="warning"
        msg="{t}info-confirm-downvote{/t}"}
    {/if}
  </div>
{/if}

<div class="vote-box col-sm-12 col-md-1">

  <div
    data-toggle="tooltip"
    data-trigger="hover"
    {if !User::getActive()}
    title="{t}tooltip-log-in-vote{/t}"
    {elseif !User::may($upvotePriv)}
    title="{t 1=$upvotePriv|nf}tooltip-minimum-reputation-upvote-%1{/t}"
    {else}
    title="{$tooltipUpvote}"
    {/if}
  >
    <button
      class="btn btn-vote {if $voteValue == 1}voted{/if}"
      {if !User::may($upvotePriv)}
      disabled style="pointer-events: none;"
      {/if}
      data-type="{$type}"
      data-object-id="{$object->id}"
      data-score-id="#score-{$type}-{$object->id}"
      data-value="1">
      <i class="icon icon-thumbs-up-alt"></i>
    </button>
  </div>

  <div id="score-{$type}-{$object->id}">{$object->getScore()|nf}</div>

  <div
    data-toggle="tooltip"
    data-trigger="hover"
    {if !User::getActive()}
    title="{t}tooltip-log-in-vote{/t}"
    {elseif !User::may($downvotePriv)}
    title="{t 1=$downvotePriv|nf}tooltip-minimum-reputation-downvote-%1{/t}"
    {else}
    title="{$tooltipDownvote}"
    {/if}
  >
    <button
      class="btn btn-vote {if $voteValue == -1}voted{/if}"
      {if !User::may($downvotePriv)}
      disabled style="pointer-events: none;"
      {/if}
      data-type="{$type}"
      data-object-id="{$object->id}"
      data-score-id="#score-{$type}-{$object->id}"
      data-value="-1">
      <i class="icon icon-thumbs-down-alt"></i>
    </button>
  </div>

  {**
    * Show the "proof" icon for answers in two situations:
    * 1. Answer is accepted as proof (read-only).
    * 2. User is moderator and can accept/unaccept answers as proof (clickable).
    **}
  {$isAnswer=($object->getObjectType() == Proto::TYPE_ANSWER)}
  {if $isAnswer && (User::isModerator() || $object->proof)}
    <div
      data-toggle="tooltip"
      data-trigger="hover"
      {if User::isModerator()}
      title="{t}tooltip-toggle-answer-proof{/t}"
      {else}
      title="{t}tooltip-answer-is-proof{/t}"
      {/if}
    >
      <button
        class="btn btn-proof {if $object->proof}accepted{/if}"
        data-answer-id="{$object->id}"
        {if !User::isModerator()}disabled style="pointer-events: none;"{/if}
      >
        <i class="icon icon-ok"></i>
      </button>
    </div>
  {/if}

</div>
