<nav class="navbar navbar-expand-md">

  <button
    class="navbar-toggler"
    type="button"
    data-toggle="slide-collapse"
    data-target="#navbar-left"
    aria-controls="navbar-left"
    aria-expanded="false"
    aria-label="{t}label-toggle-menu{/t}">
    <i class="navbar-toggler-icon icon-menu"></i>
  </button>

  <div class="navbar-collapse py-2" id="navbar-left">
    {include "bits/searchForm.tpl"}
    {***
    <ul class="navbar-nav mr-auto">
      <li class="nav-item">
        <a class="nav-link" href="#">About us</a>
      </li>
      <li class="nav-item">
        <a class="nav-link" href="#">Team</a>
      </li>
    </ul>
    ***}
  </div>

  <!-- logo -->
  <div class="mx-auto">
    <a class="navbar-brand" href="{Config::URL_PREFIX}">DIGNITAS</a>
  </div>

  <button
    class="navbar-toggler"
    type="button"
    data-toggle="slide-collapse"
    data-target="#navbar-right"
    aria-controls="navbar-right"
    aria-expanded="false"
    aria-label="{t}label-toggle-menu{/t}">
    <span class="icon icon-user"></span>
  </button>

  <div class="navbar-collapse" id="navbar-right">

    <ul class="navbar-nav ml-auto">
      <li class="nav-item">
        <a
          class="nav-link capitalize-first-word pl-2 py-2"
          href="{Router::link('help/index')}"
          title="{t}help-center{/t}"
        >
          {t}help-center{/t}
        </a>
      </li>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle pl-2 py-2"
          href="#"
          id="nav-dropdown-lang"
          role="button"
          data-toggle="dropdown"
          aria-haspopup="true"
          aria-expanded="false">
          <i class="icon icon-globe"></i>
        </a>
        <div class="dropdown-menu py-0" aria-labelledby="nav-dropdown-lang">
          {foreach LocaleUtil::getAll() as $id => $name}
            <a
              class="dropdown-item text-light pl-2 py-2"
              href="{Router::link('helpers/changeLocale')}?id={$id}">
              <i class="icon icon-ok {if $id != LocaleUtil::getCurrent()}invisible{/if}"></i>
              {$name}
            </a>
          {/foreach}
        </div>
      </li>

      {$u=User::getActive()}
      {if $u}
        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle pl-2 py-2"
            href="#"
            id="nav-dropdown-user"
            role="button"
            data-toggle="dropdown"
            aria-haspopup="true"
            aria-expanded="false">
            {if $u->fileExtension}
              {include "bits/image.tpl"
                obj=$u
                geometry=Config::THUMB_USER_NAVBAR
                imgClass="rounded"}
            {else}
              <i class="icon icon-user"></i>
            {/if}
            {$u}
            <span class="badge badge-secondary align-text-top">
              {$u->getReputation()|nf}
            </span>
          </a>
          <div class="dropdown-menu dropdown-menu-right py-0" aria-labelledby="nav-dropdown-user">
            <a class="dropdown-item text-light py-2" href="{Router::userLink($u)}">
              <i class="icon icon-user"></i>
              {t}link-my-profile{/t}
            </a>
            <a class="dropdown-item text-light py-2" href="{Router::link('aggregate/dashboard')}">
              <i class="icon icon-gauge"></i>
              {t}link-dashboard{/t}
            </a>
            {if Config::DEVELOPMENT_MODE}
              <div class="dropdown-divider"></div>
              <form id="rep-change" class="px-4 text-light">
                <small class="form-text mb-2">
                  {t}info-reputation-manual{/t}
                </small>
                <div class="form-group">
                  <input
                    type="text"
                    class="form-control"
                    id="fakeReputation"
                    placeholder="{t}label-reputation{/t}">
                </div>

                <div class="form-row align-items-center">
                  <div class="col-6">
                    <div class="custom-control custom-checkbox mr-sm-2">
                      <input
                        type="checkbox"
                        class="custom-control-input"
                        id="fakeModerator"
                        {if User::isModerator()}checked{/if}>
                      <label class="custom-control-label text-dark" for="fakeModerator">
                        {t}label-moderator{/t}
                      </label>
                    </div>
                  </div>
                  <div class="col-6 text-right">
                    <button type="submit" class="btn btn-sm btn-secondary">
                      {t}link-change{/t}
                    </button>
                  </div>
                </div>

              </form>
            {/if}
            <div class="dropdown-divider"></div>
            <a class="dropdown-item text-light py-2" href="{Router::link('auth/logout')}">
              <i class="icon icon-logout"></i>
              {t}link-log-out{/t}
            </a>
          </div>
        </li>
      {else}
        <li class="nav-item">
          <a class="nav-link capitalize-first-word" href="{Router::link('auth/login')}">
            {t}link-log-in{/t}
          </a>
        </li>
      {/if}

    </ul>

  </div>
</nav>
