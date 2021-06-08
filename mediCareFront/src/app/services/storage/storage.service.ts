import {Injectable} from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class StorageService {
  constructor() {
  }

  setDataInLocalStorage(variableName: string, data: string) {
    localStorage.setItem(variableName, data);
  }

  getJwtToken() {
    return localStorage.getItem('token');
  }

  getId() {
    return localStorage.getItem('id')
  }

  getUsername() {
    return localStorage.getItem('username')
  }

  clearStorage() {
    localStorage.clear();
  }
}
