import {
  AppActions
} from '../actions';

import NoteModel from '../models/NoteModel';

export interface NotesListState {
  state: string, // 'INIT', 'LOADING' | 'LOADED' | 'ERROR',
  notes: NoteModel[],
  errorMessage?: string
}

export function defaultNotesListState() {
  return {
    state: 'INIT',
    notes: []
  };
}


export function notesListReducer(state: NotesListState, action: AppActions): NotesListState {
  if (action.type === 'NOTES_FETCH') {
    return {
      ...state,
      state: 'LOADING',
      notes: [],
    };
  }
  if (action.type === 'NOTES_FETCH_SUCCESS') {
    return {
      ...state,
      state: 'LOADED',
      notes: action.notes,
    };
  }
  if (action.type === 'NOTES_FETCH_ERROR') {
    return {
      ...state,
      state: 'ERROR',
      notes: [],
      errorMessage: action.errorMessage
    };
  }
  return state;
}
