{* mandatory argument: $answer *}
{$voteBox=$voteBox|default:true}
{$addComment=$addComment|default:false}

<div class="answer-container row pt-2" id="a{$answer->id}">
  {if $voteBox}
    {include "bits/scoreAndVote.tpl"
      type=Vote::TYPE_ANSWER
      object=$answer
      upvotePriv=User::PRIV_UPVOTE_ANSWER
      downvotePriv=User::PRIV_DOWNVOTE_ANSWER}
  {/if}

  <div class="col-sm-12 col-md-11 mb-1">
    <div class="answer-body col-md-12 px-0">
      {$answer->contents|md}
    </div>

    {if $answer->status == Ct::STATUS_DELETED}
      <div class="alert alert-secondary small">
        {$answer->getDeletedMessage()}

        {if $answer->reason == Ct::REASON_BY_USER}
          {include "bits/userLink.tpl" u=$answer->getStatusUser()}
        {elseif $answer->reason != Ct::REASON_BY_OWNER}
          <hr>
          {include "bits/reviewFlagList.tpl" review=$answer->getRemovalReview()}
        {/if}
      </div>
    {/if}

    <div class="answer-footer col-md-12 px-0">
      <div class="text-muted mb-2 row">
        <div class="answer-read-only col-sm-12 col-md-6 mb-1">
          {t}answer-posted-by{/t}
          {include 'bits/userLink.tpl' u=$answer->getUser()}
          {include 'bits/moment.tpl' t=$answer->createDate}
        </div>

        {if $answer->verdict != Ct::VERDICT_NONE}
          <div class="col-sm-6 col-md-4 mb-1">
            <span class="badge badge-pill badge-secondary">
              <i class="icon icon-hammer"></i>
              {$answer->getVerdictName()}
            </span>
          </div>
        {/if}

        <div class="answer-actions col-sm-6 col-md-2 px-0 text-right">
          {$comments=Comment::getFor($answer)}
          {if $addComment && empty($comments)}
            {include "bits/addCommentLink.tpl" object=$answer}
          {/if}

          <button
            class="btn pt-0"
            type="button"
            id="answer-menu-{$answer->id}"
            data-toggle="dropdown"
            aria-haspopup="true"
            aria-expanded="false">
            <i class="icon icon-ellipsis-vert"></i>
          </button>

          <div class="dropdown-menu" aria-labelledby="answer-menu-{$answer->id}">
            <a href="#a{$answer->id}"
              class="dropdown-item"
              title="{t}info-answer-permalink{/t}">
              <i class="icon icon-link"></i>
              {t}link-answer-permalink{/t}
            </a>

            {include "bits/editButton.tpl" obj=$answer class="dropdown-item"}
            {include "bits/subscribeLinks.tpl" obj=$answer class="dropdown-item"}
            {include "bits/flagLinks.tpl" obj=$answer class="dropdown-item"}
            {include "bits/historyButton.tpl" obj=$answer class="dropdown-item"}
          </div>
        </div>
      </div>

    </div>

    {if !empty($comments)}
      <div class="comment-list">
        {foreach $comments as $comment}
          {include 'bits/comment.tpl'}
        {/foreach}
      </div>

      {if $addComment}
        <div class="text-muted text-right mb-2 ml-0 pl-0">
          {include "bits/addCommentLink.tpl" object=$answer}
        </div>
      {/if}
    {/if}

  </div>
</div>
<div class="border-bottom"></div>
