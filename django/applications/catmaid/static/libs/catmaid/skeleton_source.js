/* -*- mode: espresso; espresso-indent-level: 2; indent-tabs-mode: nil -*- */
/* vim: set softtabstop=2 shiftwidth=2 tabstop=2 expandtab: */

(function(CATMAID) {

  "use strict";

  /**
   * A skeleton source is an object that manages a set of skeletons of which a
   * subset can be marked as selected.
   */
  var SkeletonSource = function(register) {
    this.widgetId = register ? this.registerSource() : null;
  };

  // Operations that can be used to combine multiple sources.
  SkeletonSource.UNION = 'union';
  SkeletonSource.INTERSECTION = 'intersection';
  SkeletonSource.DIFFERENCE = 'difference';

  SkeletonSource.prototype = {};
  CATMAID.asEventSource(SkeletonSource.prototype);

  // Define event constants on prototype so they can be used on inherting
  // classes directly. THE EVENT_SOURCE_ADDED event is triggered when a skeleton
  // source was created.
  SkeletonSource.prototype.EVENT_SOURCE_ADDED = "skeleton_source_added";
  // The EVENT_SOURCE_REMOVED event is triggered when a skeleton source is
  // removed or closed.
  SkeletonSource.prototype.EVENT_SOURCE_REMOVED = "skeleton_source_removed";
  // The EVENT_MODELS_ADDED event is triggered when skeleton models were added
  // to a skeleton source. A list of skeleton models is expected as paramter.
  SkeletonSource.prototype.EVENT_MODELS_ADDED = "skeleton_source_models_added";
  // The EVENT_MODELS_REMOVED event is triggered when skeleton models were
  // removed from a source. A list of skeleton models is expected as paramter.
  SkeletonSource.prototype.EVENT_MODELS_REMOVED = "skeleton_source_models_removed";
  // The EVENT_MODELS_CHANGED event is triggered when properties of skeleton
  // source models were updated (e.g. color). A list of changed skeleton models
  // is expected as parameter
  SkeletonSource.prototype.EVENT_MODELS_CHANGED = "skeleton_source_models_changed";

  SkeletonSource.prototype.registerSource = function() {
    CATMAID.skeletonListSources.add(this);
    // Initialize subscriptions
    this.subscriptions = [];
  };

  SkeletonSource.prototype.unregisterSource = function() {
    CATMAID.skeletonListSources.remove(this);
    // Remove all event listeners
    this.clearAllEvents();
  };

  /**
   * Have this source subscribe to another skeleton source. Besides storing
   * required options this method will also register the source to relevant
   * events on the source subscribed to.
   */
  SkeletonSource.prototype.addSubscription = function(subscription) {
    // Don't allow multiple subscriptions to the same source
    var index = this.subscriptions.indexOf(subscription);
    if (-1 !== index) {
      throw new CATMAID.ValueError("Subscription already in use");
    }

    subscription.register(this);
    this.subscriptions.push(subscription);

    // Do initial update
    this.loadSubscriptions();
  };

  /**
   * Remove a subscription of this source to another source. This method will
   * also unregister this source from events of the subscribed source.
   */
  SkeletonSource.prototype.removeSubscription = function(subscription) {
    // Raise error if the subscription in question is not part of this source
    var index = this.subscriptions ? this.subscriptions.indexOf(subscription) : -1;
    if (-1 === index) {
      throw new CATMAID.ValueError("The subscription isn't part of this source");
    }

    subscription.unregister();

    // Remove subscription and update
    this.subscriptions.splice(index, 1);

    // Update
    this.loadSubscriptions();
  };

  /**
   * Get all skeleton sources this source has subscribed to.
   */
  SkeletonSource.prototype.getSourceSubscriptions = function() {
    return this.subscriptions;
  };

  /**
   * Clear and rebuild skeleton selection of this widget, based on current
   * subscription states. This is currently done in the most naive way without
   * incorporating any hinting to avoid recomputation.
   */
  SkeletonSource.prototype.loadSubscriptions = function() {

    // Find a set of skeletons that are removed and one that is added/modified
    // to not require unnecessary reloads.
    var result = this.getSkeletonModels();
    for (var i=0, max=this.subscriptions.length; i<max; ++i) {
      var sbs = this.subscriptions[i];
      var sbsModels = sbs.getModels();
      if (0 === i) {
        result = sbsModels;
        continue;
      }
      if (SkeletonSource.UNION === sbs.op) {
        // Make models of both sources available
        for (var mId in sbsModels) {
          // Use model of earleir source
          if (!result[mId]) {
            result[mId] = sbsModels[mId];
          }
        }
      } else if (SkeletonSource.INTERSECTION === sbs.op) {
        // Make models available that appear in both sources
        for (var mId in result) {
          if (!sbsModels[mId]) {
            delete result[mId]
          }
        }
      } else if (SkeletonSource.DIFFERENCE === sbs.op) {
        // Make models available that don't appear in the current source
        for (var mId in result) {
          if (sbsModels[mId]) {
            delete result[mId]
          }
        }
      } else {
        throw new CATMAID.ValueError("Unknown operation: " + sbs.op);
      }
    }

    // We now know the expected result set, compare it with the current set and
    // remove elements that are not expected anymore. Update the remainder.
    var currentSet = this.getSkeletonModels();
    if (currentSet) {
      var toRemove = [];
      for (var skid in currentSet) {
        if (!result || !(skid in result)) {
          toRemove.push(skid);
        }
      }
      if (toRemove.length > 0) {
        this.removeSkeletons(toRemove);
      }
    }

    // Update all others
    if (result) {
      this.updateModels(result);
    }
  };

  SkeletonSource.prototype.loadSource = function() {
    var models = CATMAID.skeletonListSources.getSelectedSkeletonModels(this);
    if (0 === models.length) {
      CATMAID.info('Selected source is empty.');
      return;
    }
    this.append(models);
  };

  SkeletonSource.prototype.updateOneModel = function(model, source_chain) {
    var models = {};
    models[model.id] = model;
    this.updateModels(models, source_chain);
  };

  SkeletonSource.prototype.syncLink = function(select) {
    this.linkTarget = CATMAID.skeletonListSources.getSource(select.value);
    if (this.linkTarget) {
      this.linkTarget.clear();
      this.linkTarget.append(this.getSelectedSkeletonModels());
    }
  };

  SkeletonSource.prototype.triggerChange = function(models) {
    this.trigger(this.EVENT_MODELS_CHANGED, models);
  };

  SkeletonSource.prototype.updateLink = SkeletonSource.prototype.notifyChange;

  SkeletonSource.prototype.triggerAdd = function(models) {
    this.trigger(this.EVENT_MODELS_ADDED, models);
  };

  SkeletonSource.prototype.triggerRemove = function(models) {
    this.trigger(this.EVENT_MODELS_REMOVED, models);
  };

  SkeletonSource.prototype.notifyLink = function(model, source_chain) {
    if (this.linkTarget) {
      this.linkTarget.updateOneModel(model, source_chain);
    }
  };

  SkeletonSource.prototype.clearLink = function(source_chain) {
    if (this.linkTarget) {
      if (source_chain && (this in source_chain)) return; // break propagation loop
      if (!source_chain) source_chain = {};
      source_chain[this] = this;

      this.linkTarget.clear();
    }
  };

  SkeletonSource.prototype.getLinkTarget = function() {
    return this.linkTarget;
  };

  SkeletonSource.prototype.getSelectedSkeletons = function() {
      return Object.keys(this.getSelectedSkeletonModels());
  };

  SkeletonSource.prototype.annotate_skeleton_list = function() {
    CATMAID.annotate_neurons_of_skeletons(this.getSelectedSkeletons());
  };

  /**
   * Return an array of source subscriptions that have the given source
   * associated.
   *
   * @param source The source a returned subscription will have
   */
  SkeletonSource.prototype.getSubscriptionsHavingSource = function(source) {
    return this.subscriptions.filter(function(subscription) {
      return this === subscription.source;
    }, source);
  };

  /**
   * A no-op implementation for highliing a skeleton.
   */
  SkeletonSource.prototype.highlight = function() {};

  /**
   * Represents a subscription to a skeleton source.
   *
   * @param source  The source subscribed to
   * @param colors  Indicates if source colors should be used on update
   * @param selectionBased Addition and removal are based on the selection state
   * @param op      The operation to be used to combine skeletons
   * @param mode    Optional subscription mode, which events to listen to
   * @param group   Optional group name for skeletons from source
   */
  var SkeletonSourceSubscription = function(source, colors, selectionBased, op,
      mode, group) {
    this.source = source;
    this.group = group;
    this.colors = colors;
    this.selectionBased = selectionBased;
    this.op = op;
    this.mode = mode || SkeletonSourceSubscription.ALL_EVENTS;
    this.target = null;
  };

  SkeletonSourceSubscription.ALL_EVENTS = 'all';
  SkeletonSourceSubscription.SELECTION_BASED = 'selection-based';
  SkeletonSourceSubscription.ONLY_ADDITIONS = 'additions-only';
  SkeletonSourceSubscription.ONLY_REMOVALS = 'removals-only';
  SkeletonSourceSubscription.ONLY_UPDATES = 'updates-only';

  /**
   * Register a target with this subscription and listen to events of the source
   * with respect to the selected filters. If there are any, previous targets
   * will be unregistered. A target is expected to be a skeleton source as well.
   */
  SkeletonSourceSubscription.prototype.register = function(target) {
    // Unregister from previous target, if any
    if (this.target) {
      this.unregister();
    }
    this.target = target;

    var allEvents = this.mode === CATMAID.SkeletonSourceSubscription.ALL_EVENTS;
    var onlyRemovals = this.mode === CATMAID.SkeletonSourceSubscription.ONLY_REMOVALS;
    var onlyAdditions = this.mode === CATMAID.SkeletonSourceSubscription.ONLY_ADDITIONS;
    var onlyUpdates = this.mode === CATMAID.SkeletonSourceSubscription.ONLY_UPDATES;

    if (allEvents || onlyAdditions) {
      this.source.on(this.source.EVENT_MODELS_ADDED, this._onSubscribedModelsAdded, this);
    }
    if (allEvents || onlyRemovals) {
      this.source.on(this.source.EVENT_MODELS_REMOVED, this._onSubscribedModelsRemoved, this);
    }
    if (allEvents || onlyUpdates) {
      this.source.on(this.source.EVENT_MODELS_CHANGED, this._onSubscribedModelsChanged, this);
    }

    // Populate cache with current source state
    this.modelCache = this.getModels(true);
  };

  /**
   * Remove all listeners from the current source and drop cache.
   */
  SkeletonSourceSubscription.prototype.unregister = function() {
    var allEvents = this.mode === CATMAID.SkeletonSourceSubscription.ALL_EVENTS;
    var onlyRemovals = this.mode === CATMAID.SkeletonSourceSubscription.ONLY_REMOVALS;
    var onlyAdditions = this.mode === CATMAID.SkeletonSourceSubscription.ONLY_ADDITIONS;
    var onlyUpdates = this.mode === CATMAID.SkeletonSourceSubscription.ONLY_UPDATES;

    if (allEvents || onlyAdditions) {
      this.source.off(this.source.EVENT_MODELS_ADDED, this._onSubscribedModelsAdded, this);
    }
    if (allEvents || onlyRemovals) {
      this.source.off(this.source.EVENT_MODELS_REMOVED, this._onSubscribedModelsRemoved, this);
    }
    if (allEvents || onlyUpdates) {
      this.source.off(this.source.EVENT_MODELS_CHANGED, this._onSubscribedModelsChanged, this);
    }

    // Drop cache entry
    this.modelCache = null;
  };

  /**
   * Get all models available from this subscription. By default a cached
   * version is used, which can be disabled. If this subscription is selection
   * based, only selected models will be retrieved.
   */
  SkeletonSourceSubscription.prototype.getModels = function(nocache) {
    var getModels = this.selectionBased ? this.source.getSelectedSkeletonModels :
        this.source.getSkeletonModels();
    return nocache ? getModels.call(this.source) : this.modelCache;
  };

  /**
   * Handle the addition of new models from a subscribed source.
   */
  SkeletonSourceSubscription.prototype._onSubscribedModelsAdded = function(
      source, models, order) {
    // Update cache
    for (var mId in models) {
      this.modelCache[mId] = models[mId];
    }

    this.target.loadSubscriptions();
  };

  /**
   * Handle update of models in a subscribed source (e.g. color change).
   */
  SkeletonSourceSubscription.prototype._onSubscribedModelsUpdated = function(source, models) {
    // Update cache
    for (var mId in models) {
      this.modelCache[mId] = models[mId];
    }
    this.target.loadSubscriptions();
  };

  /**
   * Handle removal of models in a subscribed source.
   */
  SkeletonSourceSubscription.prototype._onSubscribedModelsRemoved = function(source, models) {
    // Update cache
    for (var mId in models) {
      delete this.modelCache[mId];
    }
    this.target.loadSubscriptions();
  };

  // Make skeleton source and subscription available in CATMAID namespace
  CATMAID.SkeletonSource = SkeletonSource;
  CATMAID.SkeletonSourceSubscription = SkeletonSourceSubscription;

})(CATMAID);
