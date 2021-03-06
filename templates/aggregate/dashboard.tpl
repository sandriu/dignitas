{extends "layout.tpl"}

{block "title"}{cap}{t}title-dashboard{/t}{/cap}{/block}

{block "content"}
  <div class="container my-5">
    <h1 class="mb-5">{cap}{t}title-dashboard{/t}{/cap}</h1>

    <div class="row dashboard-cards">
      {if User::may(User::PRIV_ADD_STATEMENT)}
        <div class="col-12 col-sm-12 col-lg-3 pt-2 pb-1 m-2 text-center dashcard">
          <div class="card-body">
            <h3 class="card-title">
              {include "bits/icon.tpl" i=mode_edit}
            </h3>
            <a href="{Router::link('statement/edit')}" class="stretched-link">
              {t}link-add-statement{/t}
            </a>
          </div>
        </div>
      {/if}

      {if User::may(User::PRIV_ADD_ENTITY)}
        <div class="col-12 col-sm-12 col-lg-3 pt-2 pb-1 m-2 text-center dashcard">
          <div class="card-body">
            <h3 class="card-title">
              {include "bits/icon.tpl" i="person_add_alt_1"}
            </h3>
            <a href="{Router::link('entity/edit')}" class="stretched-link">
              {t}link-add-entity{/t}
            </a>
          </div>
        </div>
      {/if}

      {if User::isModerator()}
        <div class="col-12 col-sm-12 col-lg-3 pt-2 pb-1 m-2 text-center dashcard">
          <div class="card-body">
            <h3 class="card-title">
              {include "bits/icon.tpl" i="insert_link"}
            </h3>
            <a href="{Router::link('domain/list')}" class="stretched-link">
              {t}link-domains{/t}
            </a>
          </div>
        </div>

        <div class="col-12 col-sm-12 col-lg-3 pt-2 pb-1 m-2 text-center dashcard">
          <div class="card-body">
            <h3 class="card-title">
              {include "bits/icon.tpl" i="text_snippet"}
            </h3>
            <a href="{Router::link('cannedResponse/list')}" class="stretched-link">
              {t}link-canned-responses{/t}
            </a>
          </div>
        </div>

        <div class="col-12 col-sm-12 col-lg-3 pt-2 pb-1 m-2 text-center dashcard">
          <div class="card-body">
            <h3 class="card-title">
              {include "bits/icon.tpl" i="insert_invitation"}
            </h3>
            <a href="{Router::link('invite/list')}" class="stretched-link">
              {t}link-invites{/t}
            </a>
          </div>
        </div>

        <div class="col-12 col-sm-12 col-lg-3 pt-2 pb-1 m-2 text-center dashcard">
          <div class="card-body">
            <h3 class="card-title">
              {include "bits/icon.tpl" i="groups"}
            </h3>
            <a href="{Router::link('entityType/list')}" class="stretched-link">
              {t}link-entity-types{/t}
            </a>
          </div>
        </div>

        <div class="col-12 col-sm-12 col-lg-3 pt-2 pb-1 m-2 text-center dashcard">
          <div class="card-body">
            <h3 class="card-title">
              {include "bits/icon.tpl" i="compare_arrows"}
            </h3>
            <a href="{Router::link('relationType/list')}" class="stretched-link">
              {t}link-relation-types{/t}
            </a>
          </div>
        </div>

        <div class="col-12 col-sm-12 col-lg-3 pt-2 pb-1 m-2 text-center dashcard">
          <div class="card-body">
            <h3 class="card-title">
              {include "bits/icon.tpl" i="integration_instructions"}
            </h3>
            <a href="{Router::link('staticResource/list')}" class="stretched-link">
              {t}link-static-resources{/t}
            </a>
          </div>
        </div>
      {/if}

      <div class="col-12 col-sm-12 col-lg-3 pt-2 pb-1 m-2 text-center dashcard">
        <div class="card-body">
          <h3 class="card-title">
            {include "bits/icon.tpl" i="local_offer"}
          </h3>
          <a href="{Router::link('tag/list')}" class="stretched-link">
            {t}link-tags{/t}
          </a>
        </div>
      </div>

      <div class="col-12 col-sm-12 col-lg-3 pt-2 pb-1 m-2 text-center dashcard">
        <div class="card-body">
          <h3 class="card-title">
            {include "bits/icon.tpl" i="map"}
          </h3>
          <a href="{Router::link('region/list')}" class="stretched-link">
            {t}link-regions{/t}
          </a>
        </div>
      </div>
    </div>

    {if User::may(User::PRIV_REVIEW) && !empty($activeReviewReasons)}
      <h4 class="mt-5">{cap}{t}title-review-queues{/t}{/cap}</h4>

      <ul class="row dashboard-cards list-unstyled pl-0">
        {foreach $activeReviewReasons as $r}
          <li class="col-12 col-sm-12 col-lg-4 py-3 m-2 text-center dashcard">
            <a href="{Router::link('review/view')}/{Review::getUrlName($r)}" class="capitalize-first-word stretched-link">
              {Review::getDescription($r)}
            </a>
          </li>
        {/foreach}
      </ul>
    {/if}

    {if User::isModerator()}
      {if $numBadVerdicts}
        <h4 class="mt-5">{cap}{t}title-reports{/t}{/cap}</h4>

        <ul class="row dashboard-cards list-unstyled pl-0">
          <li class="col-12 col-sm-12 col-lg-4 py-3 m-2 text-center dashcard">
            <a href="{Router::link('statement/verdictReport')}" class="capitalize-first-word stretched-link">
              {t}link-verdict-report{/t}
            </a>
            ({$numBadVerdicts})
          </li>
        </ul>
      {/if}
    {/if}
  </div>
{/block}
