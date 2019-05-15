{$entityImages=$entityImages|default:true}

{foreach $statements as $s}
  <div class="statement clearfix">
    {$entity=$s->getEntity()}
    {include "bits/image.tpl"
      obj=$entity
      condition=$entityImages && $entity->imageExtension
      size=Config::THUMB_ENTITY_LARGE
      imgClass="img-thumbnail rounded float-right ml-5"}

    <div>
      <div>
        <a href="{Router::link('statement/view')}/{$s->id}">
          {$s->summary|escape}
        </a>
      </div>

      <div class="text-right">
        — {include "bits/entityLink.tpl" e=$entity},
        {$s->dateMade|ld}
      </div>

      <div class="text-right text-muted small">
        {t}added by{/t} <b>{$s->getUser()|escape}</b>
        {$s->createDate|moment}
      </div>
    </div>
  </div>
{/foreach}
